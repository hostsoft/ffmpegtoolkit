FILE(REMOVE_RECURSE
  "libx265.pdb"
  "libx265.a"
)

# Per-language clean rules from dependency scanning.
FOREACH(lang)
  INCLUDE(CMakeFiles/x265-static.dir/cmake_clean_${lang}.cmake OPTIONAL)
ENDFOREACH(lang)
