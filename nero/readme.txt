*************************************************************
*                                                           *
*  Nero AAC Encoder                                         *
*  Copyright 2008 Nero AG                                   *
*  All Rights Reserved Worldwide                            *
*                                                           *
*  Package build date: Sep 17 2008                          *
*  Package version:    1.3.3.0                              *
*                                                           *
*  See -help for a complete list of available parameters.   *
*                                                           *
*************************************************************

Usage:
neroAacEnc [options] -if <input-file> -of <output-file>

Where:
<input-file>  : Path to source file to encode.
                The file must be in Microsoft WAV format and contain PCM data.
                Specify - to encode from stdin.
<output-file> : Path to output file to encode to, in MP4 format.

  ==== Available options: ====

Quality/bitrate control:
-q <number>   : Enables "target quality" mode.
                <number> is a floating-point number in 0...1 range.
-br <number>  : Specifies "target bitrate" mode.
                <number> is target bitrate in bits per second.
-cbr <number> : Specifies "target bitrate (streaming)" mode.
                <number> is target bitrate in bits per second.
                When neither of above quality/bitrate options is used,
                the encoder defaults to equivalent of -q 0.5

Multipass encoding:
-2pass        : Enables two-pass encoding mode.
                Note that two-pass more requires a physical file as input,
                rather than stdin.
-2passperiod  : Overrides two-pass encoding bitrate averaging period,
  <number>    : in milliseconds.
              : Specify zero to use least restrictive value possible (default).

Advanced features / troubleshooting:
-lc           : Forces use of LC AAC profile (HE features disabled)
-he           : Forces use of HE AAC profile (HEv2 features disabled)
-hev2         : Forces use of HEv2 AAC profile
                Note that the above switches (-lc, -he, -hev2) should not be
                used; optimal AAC profile is automatically determined from
                quality/bitrate settings when no override is specified.
-ignorelength : Ignores length signaled by WAV headers of input file.
                Useful for certain frontends using stdin.
