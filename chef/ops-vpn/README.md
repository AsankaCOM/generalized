# ops-vpn

To install an openvpn server you need to run the ops-vpn::default recipe.

## ops-vpn::default

The default recipe download the openvpn package and install it using dpkg instruction, so you need to use an Ubuntu AMI for this.
Also the recipe creates an user called openvpn and set a password specify in the attributes file. The default recipe calls two recipes

- ops-vpn::alert
- ops-vpn::dump


## ops-vpn::alert

The alert recipe copy and paste a configuration file who captures all the alerts and send them to a Slack's channel. Also create a cron job
to do all the report every 2 minutes.

## ops-vpn::dump

The dump recipe is used to create the log files and the backup.

## Secundary recipes
- ops-vpn::ratelimit: To increase the rate limit
- ops-vpn::secure: To disable the initial account
- ops-vpn::unban: To unlock a banned user
- ops-vpn::unlock-mfa: To unlock the mfa Google authentification

## Attributes

<table>
  <tr>
    <th>Variable</th>
    <th>Description</th>
  </tr>

  <tr>
  <td>default['openvpn']['password']</td>
  <td>Main password for openvpn</td>
  </tr>

  <tr>
  <td>default['vpn']['slack']['url']</td>
  <td>Slack hook url</td>
  </tr>

  <tr>
  <td>default['vpn']['backup']</td>
  <td>S3 location where the backups will be saving. (bucket_name/folder_backups for example)</td>
  </tr>

  <tr>
  <td>default['vpn']['log']</td>
  <td>S3 location where the log will be saving. (bucket_name/folder_logs for example)</td>
  </tr>
</table>
