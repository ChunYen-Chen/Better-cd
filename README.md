## Setup
1. Copy this file to somewhere (e.g. `~/Better_cd.sh`).
1. Add the following line to your `.bashrc`:
   ```shell
   source ~/Better_cd.sh
   ```
1. Resource the `.bashrc` by executing the command:
   ```shell
   source ~/.bashrc
   ```

## Usage
1. `cd` now also records `pwd` to the `.dir_history`
1. `cdl` list the directories you have been to.
1. `cdl 20` list 20 directories you have been to.
1. `cdd` go to the last directory
1. `cdd 4` go to the fourth directory listed by `cdl`
