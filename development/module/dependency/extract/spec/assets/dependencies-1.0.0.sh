#!/bin/sh

module "normal" "https://mdl.sh/normal-1.0.0.sh" "cksum-123"
module plain https://mdl.sh/plain-1.0.0.sh cksum-123
module 'single' 'https://mdl.sh/single-1.0.0.sh' 'cksum-123'
module mixed 'https://mdl.sh/mixed-1.0.0.sh' "cksum-123"
  module "Spaces" "https://mdl.sh/spaces-1.0.0.sh" "cksum-123"
  module  "Spaces2"  "https://mdl.sh/spaces2-1.0.0.sh" "cksum-123"
	module "Tabs" "https://mdl.sh/tabs-1.0.0.sh" "cksum-123"
module		"Tabs2"		"https://mdl.sh/tabs2-1.0.0.sh" "cksum-123"

module "path" "https://mdl.sh/path/path-1.0.0.sh" "cksum-123"
module "path2" "https://mdl.sh/path/path2/path2-1.0.0.sh" "cksum-123"

module "noChecksum" "https://mdl.sh/no-ckecksum-1.0.0.sh"
module "nonmdl" "https://example.com/nonmdl-1.0.0.sh"

