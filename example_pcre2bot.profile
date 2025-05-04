# example_pcre2bot.profile — pcre2bot's firejail profile example
#
# Description:
#   Run pcre2bot in a sandbox.
#
# Usage:
#   firejail --quiet --profile=./example_pcre2bot.profile ./pcre2bot example_pcre2bot.toml --ac
#
# Notes:
#   - This profile can be useful if the user wants to sandbox pcre2bot while being
#     able to interact with it, since systemd services are detached from TTY.
#     The drawback is that it cannot control resources efficiently like systemd.
#
#   - If logging is enabled and the log filepath is different than ~/pcre2bot/irclogs,
#     it will need to be set (e.g. in a whitelist: 'mkdir /tmp/irclogs', 'whitelist /tmp/irclogs').
#
# References:
#   https://firejail.wordpress.com/
#   https://wiki.archlinux.org/title/Firejail
#   https://man.archlinux.org/man/firejail.1
#   https://man.archlinux.org/man/firejail-profile.5
#   https://firejail.wordpress.com/documentation-2/building-custom-profiles/
#   https://github.com/netblue30/firejail/wiki/Creating-Profiles
#   https://github.com/netblue30/firejail/wiki/Comparison-of-firejail-and-systemd's-hardening-options

# Firejail profile for pcre2bot
# Description: pcre2bot IRC bot
# This file is overwritten after every install/update
#quiet
# Persistent local customizations
include pcre2bot.local
# Persistent global definitions
include globals.local

ignore noexec ${HOME}

# Allow /bin/sh (blacklisted by disable-shell.inc)
# Note that /bin/sh is required to check if pcre2test is installed on user's system.
include allow-bin-sh.inc

# Allow perl (blacklisted by disable-interpreters.inc)
include allow-perl.inc

# Disable /run/user/UID
blacklist ${RUNUSER}

blacklist /usr/libexec

include disable-common.inc
include disable-devel.inc
include disable-exec.inc
include disable-interpreters.inc
include disable-proc.inc
include disable-programs.inc
include disable-shell.inc
include disable-write-mnt.inc
include disable-x11.inc
include disable-xdg.inc

# Hide $HOME directory while allowing ~/perl5 (perlbrew's dir) directory to be
# readable; also ~/pcre2bot read-writeable.
#
# Notes:
#   - This allows pcre2bot to access perlbrew's perl + cpanm modules. Also pcre2bot's
#     dir will be persistent and able to write to its logs.
#   - Because of sandboxing, any log dirs in ~/pcre2bot (e.g. irclogs), must be
#     created before starting the service.
mkdir ${HOME}/pcre2bot/irclogs
whitelist-ro ${HOME}/perl5
whitelist ${HOME}/pcre2bot

# Hide /tmp while allowing /tmp/pcre2bot directory to be used for the Unix socket file.
mkdir /tmp/pcre2bot
whitelist /tmp/pcre2bot

caps.drop all
machine-id
# Uncomment and replace 'interface' with a working network interface, to isolate
# it. Run 'ip a' or networkctl to check available interfaces.
#net interface
netfilter
no3d
nodvd
nogroups
noinput
nonewprivs
noprinters
noroot
nosound
notpm
notv
nou2f
novideo
protocol unix,inet,inet6
seccomp
# Control resources.
#
# Note that pcre2bot's CPU and memory usage is small, so it should not go beyond
# the configured options values, unless pcre2test's output is very large and the
# max_paste_lines value high enough to hold that.
#
# Lower pcre2bot's scheduling priority.
nice 2
# Protect the system by limiting memory usage in case of memory leaks.
rlimit-as 1g

# For some reason private-bin does not work.
#private-bin perl
private-cache
private-dev
private-tmp

dbus-system none
dbus-user none

restrict-namespaces
