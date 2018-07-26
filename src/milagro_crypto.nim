# milagro_crypto
# Copyright (c) 2018 Status Research & Development GmbH
# Licensed and distributed under the Apache v2 license (license terms in the root directory or at http://www.apache.org/licenses/LICENSE-2.0).
# This file may not be copied, modified, or distributed except according to those terms.

import strutils, macros
from os import DirSep

const cSourcesPath = currentSourcePath.rsplit(DirSep, 1)[0] & "/generated"
{.passC: "-I" & cSourcesPath .}
{.pragma: amcl, importc, cdecl.}

macro compileFilesFromDir(path: static[string], fileNameBody: untyped): untyped =
  # Generate the list of compile statement like so:
  # {.compile: "src/generated/fp_BLS381.c".}
  # {.compile: "src/generated/ecdh_BLS381.c".}
  # ...
  #
  # from
  # compileFilesFromDir("src/generated/"):
  #   "fp_BLS381.c"
  #   "ecdh_BLS381.c"
  #   ...

  result = newStmtList()

  for file in fileNameBody:
    assert file.kind == nnkStrLit
    result.add nnkPragma.newTree(
      nnkExprColonExpr.newTree(
        newIdentNode("compile"),
        newLit(path & $file)
      )
    )

compileFilesFromDir("generated/"):
  "oct.c"
  "aes.c"
  "hash.c"
  "ecdh_support.c"
  "rand.c"
  "big_384_29.c"
  "rom_field_BLS381.c"
  "fp_BLS381.c"
  "rom_curve_BLS381.c"
  "ecp_BLS381.c"
  "ecdh_BLS381.c"
  "randapi.c"

type
  Octet* {.importc: "octet", header: cSourcesPath & "/amcl.h", bycopy.} = object
    len* {.importc: "len".}: cint # Length in bytes
    max* {.importc: "max".}: cint # Max length allowed - enforce truncation
    val* {.importc: "val".}: ptr UncheckedArray[byte] # Byte array

  EcdhError* = enum
    Invalid = -4
    Error = -3
    InvalidPublicKey = -2
    Ok = 0

  Csprng* {.importc: "csprng", header: cSourcesPath & "/amcl.h", bycopy.} = object
    ## Opaque cryptographically secure pseudo-random number generator

proc OCT_fromHex(dst: ptr Octet, src: cstring) {.amcl.}

proc create_csprng(csprng: ptr Csprng, seed: ptr Octet) {.amcl.}

proc ecp_bls381_key_pair_generate(csprng: ptr Csprng, privkey, out_pubkey: ptr Octet) {.amcl.}


when isMainModule:
  ## Check Octet

  var backend: array[64, byte]
  var x = Octet(len: 0, max: 64, val: cast[ptr UncheckedArray[byte]](backend.addr))
  let y = "1234"

  x.addr.OCT_fromHex(y)

  echo "length: " & $x.len
  for i in 0 ..< x.len:
    echo "byte " & $i & ": " & $x.val[i]
