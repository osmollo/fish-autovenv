## AutoVenv Settings
if status is-interactive
  test -z "$autovenv_announce"
  and set -g autovenv_announce "yes"
  test -z "$autovenv_enable"
  and set -g autovenv_enable "yes"
  test -z "$autovenv_dir"
  and set -g autovenv_dir ".venv"
end

# Apply autovenv settings.
function applyAutoenv
  # Check for the enable flag and make sure we're running interactive, if not return.
  test ! "$autovenv_enable" = "yes"
  or not status is-interactive
  and return
  # We start by splitting our CWD path into individual elements and iterating over each element.
  # If our CWD is `/opt/my/hovercraft/eels` we split it into a variable containing 4 entries:
  # `opt`, `my`, `hovercraft` and `eels`. We then iterate over each entry and check to see if it
  # contains a `bin/activate.fish` file. If a venv is found we go ahead and break out of the loop,
  # otherwise continue. We go through all of this instead of just checking the CWD to handle cases
  # where the user moves into a sub-directory of the venv.

  set _pwd (pwd)
  if string match -q '/*' "$autovenv_dir"
    set -l _basename (basename $_pwd)
    if test -d $autovenv_dir/$_basename
      set _activate (string join '/' "$autovenv_dir" "$_basename" "bin/activate.fish")
      echo "_pwd: $_pwd"
      echo "_basename: $_basename"
      echo "_activate: $_activate"
      # if virtual_env is not activated
      if test -z "$VIRTUAL_ENV"
        source "$_activate"
        cd (pwd)
        set _active_new $_basename
        echo "_active_new: $_active_new"
        if test "$autovenv_announce" = "yes"
          echo "Activated Virtual Environment ($_active_new)"
        end
      # else if there is and activated venv
      else
        # si el virtualenv cargado no esta en la ruta...
        if ! string match -q "*$_active_new*" "$_pwd"
          deactivate
          if test "$autovenv_announce" = "yes"
            echo "Deactivated Virtual Enviroment ($_active_new)"
          end
        end
      end
    end
  end
end

# We need to run AutoVenv on the initialization of each session.
if status is-interactive
  applyAutoenv
end

## AutoVenv Function.
# Activates on directory changes.
function autovenv --on-variable PWD -d "Automatic activation of Python virtual environments"
  applyAutoenv
end
