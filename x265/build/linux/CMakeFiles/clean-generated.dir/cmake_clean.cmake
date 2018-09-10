FILE(REMOVE_RECURSE
  "CMakeFiles/clean-generated"
)

# Per-language clean rules from dependency scanning.
FOREACH(lang)
  INCLUDE(CMakeFiles/clean-generated.dir/cmake_clean_${lang}.cmake OPTIONAL)
ENDFOREACH(lang)
