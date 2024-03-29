# Script to download translations from poeditor
#
# Prerequisites:
#
# 1. Add a poeditor.properties file
# It should declare the variables:
# PE_API_TOKEN="Api Token"
# PE_PROJECT_ID="Project ID"
#
# 2. Install jq
# on MacOs using `brew install jq`
# for other operating systems check:
# https://stedolan.github.io/jq/download/
source poeditor.properties

l10nPath="../lib/src/apptive_grid_user_management/formal_german"

declare -a defaultTranslations

# The default locale should always be the first one
# to have the fallback translations for all other locales
for lang in "de_for"; do
  echo $lang
  command=$(curl -X POST https://api.poeditor.com/v2/projects/export \
    -d api_token="$PE_API_TOKEN" \
    -d id="$PE_PROJECT_ID" \
    -d language="$lang" \
    -d filters="translated" \
    -d type="key_value_json" | jq -r ".result.url")
  file="${l10nPath}/intl_$lang.json"
  curl "$command" -o "$file"

  langFile="${l10nPath}/translation_$lang.dart"

  printf "// ignore_for_file: type=lint\n" >"$langFile"
  printf "// coverage:ignore-file\n\n" >>"$langFile"
  printf "import 'package:apptive_grid_user_management/src/translation/l10n/translation_de.dart'\n              as de;\n\n" >>"$langFile"
  printf "/// Formal German Translations for ApptiveGridUserManagementTranslations\n          /// to use this instead of the default Strings that address the user with 'DU' add this to the ApptiveGridUserManagement Widget like this\n          ///\n          /// \`\`\`\n          /// ApptiveGridUserManagement(\n          ///     customTranslations: {\n          ///         const Locale.fromSubtags(languageCode: 'de'):\n          ///             FormalGermanApptiveGridUserManagementTranslation(),\n          ///         },\n          ///    ...\n          /// \`\`\`\n" >>"$langFile"
  printf "class FormalGermanApptiveGridUserManagementTranslation extends de.ApptiveGridUserManagementLocalizedTranslation {\n" >>"$langFile"
  printf "  const FormalGermanApptiveGridUserManagementTranslation() : super();\n" >>"$langFile"

  keys=($(jq -r 'keys_unsorted[]' "$file"))
  values=$(jq -r 'values[]' "$file")

  SAVEIFS=$IFS # Save current IFS
  IFS=$'\n'    # Change IFS to new line

  # Populate array of values
  declare -a array
  n=0
  for line in "${values[@]}"; do
    array+=($line)
    n=$(($n + 1))
  done

  # Print keys and values to Dart class
  n=0
  for key in "${keys[@]}"; do
    printf "\n   @override\n" >>$langFile
    if [ -z "${array[$n]}" ]; then
      translation="${defaultTranslations[$n]}"
    else
      translation="${array[$n]}"
    fi
    if [ $key == "requestResetPasswordSuccess" ]; then
      wildcard="email"
      printf "   String %s(String %s) => \'%s\';\n" $key "$wildcard" "$translation" >>$langFile
    else if [ $key == "registerConfirmAddToGroup" ]; then
      wildcardEmail="email"
      wildcardApp="app"
      printf "   String %s({required String %s, required String %s,}) => \'%s\';\n" $key "$wildcardEmail" "$wildcardApp" "$translation" >>$langFile
    else if [ $key == "joinGroup" ]; then
      wildcard="app"
      printf "   String %s(String %s) => \'%s\';\n" $key "$wildcard" "$translation" >>$langFile
     else
      printf "   String get %s => \'%s\';\n" $key "$translation" >>$langFile
    fi
    fi
    fi
    n=$(($n + 1))
  done

  IFS=$SAVEIFS # Restore IFS

  printf "}" >>"$langFile"

  # Save the default locale translations for future use
  if [ "$lang" == "en" ]; then
    defaultTranslations=("${array[@]}")
  fi
  unset array
  unset keys
  unset values
  unset translation
  unset n
done

dart format $l10nPath
