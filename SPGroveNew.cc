//
// Copyright (C) 1997 Ken MacLeod
// See the file COPYING for distribution terms.
//
// $Id: SPGroveNew.cc,v 1.3 1997/10/09 01:55:14 ken Exp $
//

// The next two lines are only to ensure bool gets defined appropriately.
#include <stdio.h>
#include <stdlib.h>
#include "config.h"
#include "Boolean.h"

#include "ParserEventGeneratorKit.h"

extern "C" {
#define explicit nexplicit
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#undef explicit

SV *sp_grove_new (char *type, char *);
}

#undef assert
#include <assert.h>

char *
as_string (SGMLApplication::CharString text) {
  static unsigned char buffer[1024+1];
  size_t str_len = text.len;
  unsigned char *cptr = &buffer[0];
  const SGMLApplication::Char *uptr = text.ptr;

  if (str_len > 1024) {
    // XXX we need to do better than this
    fprintf (stderr, "string greater than 1024\n");
    exit (1);
  }

  while (str_len--) {
    if ((*uptr & 0xff00) != 0) {
      // XXX we need to do better than this
      fprintf (stderr, "character more than 8bits\n");
      exit (1);
    }
    *cptr++ = (unsigned char) *uptr++;
  }
  *cptr = '\0';

  return ((char *)&buffer[0]);
}

class SPGrove : public SGMLApplication {
public:
  SPGrove::SPGrove(char *type, SV **grove);
  SPGrove::~SPGrove();
  void SPGrove::startElement(const StartElementEvent &event);
  void endElement(const EndElementEvent &);
  void data(const DataEvent &event);
  void sdata(const SdataEvent &event);
  void pi(const PiEvent &event);
  void error(const ErrorEvent &event);
private:
  int have_root_;		// flag indicating that we've saved the root
  AV *grove_;			// grove element, dereferenced
  AV *errors_;			// errors array, dereferenced
  AV *contents_;		// current element's contents
  AV *stack_;			// element stack
  HV *sdata_stash_;		// SData stash for blessing
  HV *element_stash_;		// Element stash for blessing
  HV *pi_stash_;		// PI stash for blessing
};

//
// This is the C-callable interface to the grove builder
//
SV *
sp_grove_new (char *type, char * file_name)
{
  SV *grove;

  ParserEventGeneratorKit parserKit;
  EventGenerator *egp = parserKit.makeEventGenerator(1, &file_name);
  SPGrove app(type, &grove);
  unsigned nErrors = egp->run(app);
  delete egp;

  return (grove);
}

SPGrove::SPGrove(char *type, SV **grove_ref) {
  grove_ = newAV();

  // create array for errors
  errors_ = newAV();
  av_push(grove_, newRV((SV*)errors_));

  // save a blessed reference for the caller
  *grove_ref = newRV((SV*)grove_);
  sv_bless (*grove_ref, gv_stashpv(type, 1));

  have_root_ = 0;
  sdata_stash_ = gv_stashpv("SGML::SData", 1);
  element_stash_ = gv_stashpv("SGML::Element", 1);
  pi_stash_ = gv_stashpv("SGML::PI", 1);
  stack_ = newAV();
}

SPGrove::~SPGrove() {
  av_undef(stack_);
}

//
// `startElement' is called at the opening of each element in the instance.
// `startElement' creates a new `element' with empty contents, the
// element's name, and any attributes.  See `SGML::Element'.
//
void SPGrove::startElement(const StartElementEvent &event) {
  SV *element[3];

  // Create empty array for contents
  AV *contents = newAV();
  element[0] = newRV((SV*)contents);

  // Name
  element[1] = newSVpv(as_string(event.gi), event.gi.len);

  // Attributes
  HV *attributes = (HV*)&sv_undef;
  size_t nAttributes = event.nAttributes;

  if (nAttributes > 0) {
    // XXX we can optimize by using a C array and av_make instead of push
    attributes = newHV();
    const Attribute *att_ptr = event.attributes;

    while (nAttributes-- > 0) {
      if (att_ptr->type == Attribute::cdata) {
	AV *att_data = newAV();
	size_t nCdataChunks = att_ptr->nCdataChunks;
	const SGMLApplication::Attribute::CdataChunk *cdataChunk
	  = att_ptr->cdataChunks;

	// XXX we can optimize by using a C array and av_make instead of push
	while (nCdataChunks-- > 0) {
	  SV *data;

	  if (cdataChunk->isSdata) {
	    SV *sdata_a[2];
	    sdata_a[0] = newSVpv(as_string(cdataChunk->data),
				 cdataChunk->data.len);
	    sdata_a[1] = newSVpv(as_string(cdataChunk->entityName),
				 cdataChunk->entityName.len);
	    AV *sdata = av_make(2, &sdata_a[0]);
	    data = newRV((SV*)sdata);
	    sv_bless (data, sdata_stash_);
	  } else if (!cdataChunk->isNonSgml) {
	    data = newSVpv(as_string(cdataChunk->data), cdataChunk->data.len);
	  } else {
	    // XXX we need to do better than this
	    fprintf (stderr, "isNonSGML in cdata attribute\n");
	    exit (1);
	  }
	  av_push (att_data, data);
	}

	hv_store (attributes,
		  as_string(att_ptr->name), att_ptr->name.len,
		  newRV((SV*)att_data), 0);
      }
      att_ptr ++;
    }
  }

  // finish off adding the attributes to the element
  if (attributes == (HV*)&sv_undef) {
    element[2] = &sv_undef;
  } else {
    element[2] = newRV((SV*)attributes);
  }

  // create a reference so we can bless it and pass it around
  SV *element_ref = newRV((SV*)av_make(3, &element[0]));
  sv_bless (element_ref, element_stash_);

  // push the old element on the stack, or save this element as the
  // root if this is the first element
  if (!have_root_) {
    have_root_ = 1;
    // grove is the second field from the one pushed in the constructor
    av_push (grove_, element_ref);
  } else {
    av_push (contents_, element_ref);
  }
  av_push (stack_, (SV*)contents_);

  // cache the contents array
  contents_ = contents;
}

//
// `endElement' is called at the closing of each element in the
// instance.  `endElement' pulls the parent element off the stack and
// copies it's contents to the `contents_' cache
//
void SPGrove::endElement(const EndElementEvent &) {
  contents_ = (AV*)av_pop(stack_);
}

//
// `data' is called when ordinary instance data comes across
//
// XXX `data' can be optimized
// SP is a bit overzealous with it's parsing of data, it breaks at
// every whitespace and creates a new data event.  We can optimize by
// concatenating the data events into one object.  But to do this, we
// don't know when ``the last data event'' is, so we have to modify
// all the event handlers to clean up before their turn.  See `nsgmls'
// because it does this also.
void SPGrove::data(const DataEvent &event) {
  av_push(contents_, newSVpv(as_string(event.data), event.data.len));
}

//
// `sdata' is called when sdata comes through
// sdata is blessed into the SGML::SData class
//
void SPGrove::sdata(const SdataEvent &event) {
  SV *sdata_a[2];
  sdata_a[0] = newSVpv(as_string(event.text), event.text.len);
  sdata_a[1] = newSVpv(as_string(event.entityName), event.entityName.len);
  AV *sdata = av_make(2, &sdata_a[0]);
  SV *sdata_ref = newRV((SV*)sdata);

  sv_bless (sdata_ref, sdata_stash_);
  av_push(contents_, sdata_ref);
}

//
// `pi' is called for process instructions
// processing instructions are blessed into SGML::PI
//
void SPGrove::pi(const PiEvent &event) {
  SV *pi = newSVpv(as_string(event.data), event.data.len);
  SV *pi_ref = newRV(pi);

  sv_bless (pi_ref, pi_stash_);
  av_push(contents_, pi_ref);
}

//
// `error' is called when an error is encountered during the pars.
//
void SPGrove::error(const ErrorEvent &event) {
  av_push(errors_, newSVpv(as_string(event.message), event.message.len));
}

