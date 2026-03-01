function claude
    if not type -q aws
        command claude $argv
        return $status
    end

    set -l profile default
    if set -q AWS_PROFILE
        set profile $AWS_PROFILE
    end

    # Avoid AWS checks on every run; refresh only once per 8 hours.
    set -l cache_dir ~/.config/fish/.cache
    set -l cache_file "$cache_dir/claude-aws-$profile.stamp"
    set -l now (date +%s)
    set -l max_age (math 60 \* 60 \* 8)
    set -l needs_refresh 1

    if test -f $cache_file
        set -l last (string trim -- (cat $cache_file))
        if string match -qr '^[0-9]+$' -- $last
            set -l age (math "$now - $last")
            if test $age -lt $max_age
                set needs_refresh 0
            end
        end
    end

    if test $needs_refresh -eq 1
        aws sts get-caller-identity --profile $profile >/dev/null 2>&1
        if test $status -ne 0
            aws sso login --profile $profile
            if test $status -ne 0
                return $status
            end
        end
        if not test -d $cache_dir
            mkdir -p $cache_dir
        end
        echo $now > $cache_file
    end

    command claude $argv
end
