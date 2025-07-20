# Fragment

## Important

- The project follows the guidelines set forth in https://mywiki.wooledge.org/BashPitfalls

## Overview

- Fragment is a bash function that produces a complete document from fragments.  

- `fzf` and `jq` are required to be present in the PATH

- Fragment references data in the "$HOME/.fragment" folder

- The directory structure is as follows

  > - .fragment/
  >   - project-name/
  >     - _fragment.config.json
  >     - some-file-name.fragment.actual-extension

- The `_fragment.config.json` will contain

  ```json
  {
      order: [
          "some-file-name.extension"
      ]
  }
  ```

- calling `fragment <project-name>` should present the user with a list of `*.fragment.*` files (minus the .fragment. piece), and using fzf they should be able to multi select the options they want.  fragment will then look at the `_fragment.config.json` in the applicable project folder, and create a new artifact from all the selected files, in the order outlined in the `order` array of the config. 