# GitNow — Speed up your Git workflow. 🐠
# https://github.com/joseluisq/gitnow

function __gitnow_new_branch_switch
  set -l branch_name $argv[1]

  if test (count $argv) -eq 1
    set branch_name $branch_name

    command git checkout -b $branch_name
  else
    echo "Provide a branch name."
  end
end

# adapted from https://gist.github.com/oneohthree/f528c7ae1e701ad990e6
function __gitnow_slugify
  echo $argv | command iconv -t ascii//TRANSLIT | command sed -E 's/[^a-zA-Z0-9]+/_/g' | command sed -E 's/^(-|_)+|(-|_)+$//g' | command tr A-Z a-z
end

function __gitnow_clone_repo
  set -l repo $argv[1]
  set -l platform $argv[2]

  if test -n "$repo"
    set -l ok 1

    if echo $repo | command grep -q -E '^[\%S].+'
      set -l user (command git config --global user.$platform)

      if test -n "$user"
        set -l repor (echo $repo | command sed -e "s/^%S/$user/")
        set repo $repor
      else
        set ok 0
      end
    end

    if test $ok -eq 1
      if [ "$platform" = "github" ]
        set url github.com
      end

      if [ "$platform" = "bitbucket" ]
        set url bitbucket.org
      end

      set -l repo_url git@$url:$repo.git
      
      echo "📦 Remote repository: $repo_url"
      command git clone $repo_url
    else
      __gitnow_clone_msg $platform
    end
  else
    __gitnow_clone_msg $platform
  end
end

function __gitnow_clone_msg
  set -l msg $argv[1]

  echo "Repository name is required!"
  echo "Example: $msg your-repo-name"
  echo "Usages:"
  echo "  a) $msg username/repo-name"
  echo "  b) $msg username repo-name"
  echo "  c) $msg repo-name"
  echo "     For this, it's necessary to set your $msg username (login)"
  echo "     to global config before like: "
  echo "     git config --global user.$msg \"your-username\""
  echo
end

function __gitnow_check_if_branch_exist
  if test (count $argv) -eq 1
    set -l xbranch $argv[1]
    set -l xbranch_list (__gitnow_current_branch_list)
    set -l xfound 0

    for b in $xbranch_list
      if [ "$xbranch" = "$b" ]
        set xfound 1
        break
      end
    end

    echo $xfound
  else
    echo "Provide a valid branch name."
  end
end

function __gitnow_clone_params
  set -l repo

  if count $argv > /dev/null
    if test (count $argv) -gt 1
      set repo $argv[1]/$argv[2]
    else if echo $argv | command grep -q -E '^([a-zA-Z0-9\_\-]+)\/([a-zA-Z0-9\_\-]+)$'
      set repo $argv
    else
      set repo "%S/$argv"
    end
  end

  echo $repo
end

function __gitnow_current_branch_name
  command git symbolic-ref --short HEAD 2>/dev/null
end

function __gitnow_current_branch_list
  command git branch --list --no-color | sed -E "s/^(\*?[ \t]*)//g" 2>/dev/null
end

function __gitnow_current_remote
  set -l branch_name (__gitnow_current_branch_name)
  command git config "branch.$branch_name.remote" 2>/dev/null; or echo origin
end

function __gitnow_current_commit_short
  command git rev-parse --short HEAD 2>/dev/null
end
