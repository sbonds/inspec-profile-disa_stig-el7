# encoding: utf-8
#
# Support for passed in Atrributes
disable_slow_controls = attribute(
  'disable_slow_controls',
  default: false,
  description: 'If enabled, this attribute disables this control and other
                controls that consistently take a long time to complete.'
)
rpm_verify_perms_except = attribute(
  'rpm_verify_perms_except',
  default: [],
  description: 'This is a list of system files that should be allowed to change
                permission attributes from an rpm verify point of view.')

control "V-71849" do
  title "The file permissions, ownership, and group membership of system files
and commands must match the vendor values."
   if disable_slow_controls
    desc "This control consistently takes a long to run and has been disabled
using the disable_slow_controls attribute."
   else
  desc  "Discretionary access control is weakened if a user or group has access
permissions to system files and directories greater than the default."
   end
  impact 0.7
  tag "gtitle": "SRG-OS-000257-GPOS-00098"
  tag "satisfies": ["SRG-OS-000257-GPOS-00098", "SRG-OS-000278-GPOS-00108"]
  tag "gid": "V-71849"
  tag "rid": "SV-86473r2_rule"
  tag "stig_id": "RHEL-07-010010"
  tag "cci": ["CCI-001494", "CCI-001496"]
  tag "documentable": false
  tag "nist": ["AU-9", "AU-9 (3)", "Rev_4"]
  tag "check": "Verify the file permissions, ownership, and group membership of
system files and commands match the vendor values.

Check the file permissions, ownership, and group membership of system files and
commands with the following command:

# rpm -Va | grep '^.M'

If there is any output from the command indicating that the ownership or group
of a system file or command, or a system file, has permissions less restrictive
than the default, this is a finding."
  tag "fix": "Run the following command to determine which package owns the
file:

# rpm -qf <filename>

Reset the permissions of files within a package with the following command:

#rpm --setperms <packagename>

Reset the user and group ownership of files within a package with the following
command:

#rpm --setugids <packagename>"
  tag "fix_id": "F-78201r3_fix"
  # @todo add puppet content to fix any rpms that get out of wack
# The following are known to be different and must be excluded. These are changed by the following
# Chef Manage Cookbooks:
# cron entries - stig/recipies/file_permissions.rb
#.M.......  /etc/cron.d
#.M.......  /etc/cron.daily
#.M.......  /etc/cron.hourly
#.M.......  /etc/cron.monthly
#.M.......  /etc/cron.weekly
#.M.......  c /etc/crontab
# /etc/default/useradd - stig/recipies/login_defs.rb
#.M5....T.  c /etc/default/useradd
# /etc/ntp.conf - stig/recipies/ntp.rb
#.M.......  c /etc/ntp.conf
# /etc/sysctl.conf - stig
#SM5....T.  c /etc/sysctl.conf
#
#/etc/default/useradd - stig/recipies/ipv6.rb
#SM5....T.  c /etc/sysconfig/iptables
# /var/cache/yum -  if you ever clear out the yum cache to free system space
#.M.......    /var/cache/yum
  if disable_slow_controls
    describe "This control consistently takes a long time to run and has been disabled
    using the disable_slow_controls attribute." do
      skip "This control consistently takes a long time to run and has been disabled
            using the disable_slow_controls attribute. You must enable this control for a
            full accredidation for production."
    end
  else
    describe command("rpm -Va | grep '^.M' | awk 'NF>1{print $NF}'").stdout.strip.split("\n") do
      it { should all(be_in rpm_verify_perms_except) }
    end
  end
end
