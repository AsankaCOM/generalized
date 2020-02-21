# ops-jenkins

To install a jenkins server you need to run the ops-jenkins::default recipe.

## Cookbook Dependencies


- Jenkins version 2.4.1
You can ee the official documentation here
https://supermarket.chef.io/cookbooks/jenkins/versions/2.4.1

- Java version 1.39.0
You can see the official documentation here
https://supermarket.chef.io/cookbooks/java/versions/1.39.0

- Awscli version 1.1.2
You can see the official documentation here
https://supermarket.chef.io/cookbooks/awscli

- apt version 2.9.2
You can see the official documentation here
https://supermarket.chef.io/cookbooks/apt/versions/2.9.2

- ssh_known_hosts version 2.0.0
You can see the official documentation here
https://supermarket.chef.io/cookbooks/ssh_known_hosts/versions/2.0.0

- ops-caddy::default It is used with Jenkins SSL

- ops-base Cookbook that install some packages and plugins that will be useful.

- Python Install components using pip command


# ops-jenkins::default

This recipe is used to download and install jenkins plugins such as git, git client and slack. Creates the main directories for our jenkins server and create a user and calls another recipes.

# ops-jenkins::plugins

This recipe includes all the plugins that you can install using chef. You can include more or remove them.

# Attributes

<table>
  <tr>
    <th>Variable</th>
    <th>Description</th>
  </tr>

  <tr>
  <td>default['java']['install_flavor']</td>
  <td>Oracle by default</td>
  </tr>

  <tr>
  <td>default['java']['jdk_version']</td>
  <td>JDK versio, 8 by default</td>
  </tr>

  <tr>
  <td>default['java']['accept_license_agreement']</td>
  <td>Must be true</td>
  </tr>

  <tr>
  <td>default['java']['oracle']['accept_oracle_download_terms']</td>
  <td>Must be true</td>
  </tr>

  <tr>
  <td>default['jenkins']['master']['install_method']</td>
  <td>Kind of instalation method, package by default</td>
  </tr>

  <tr>
  <td>default['caddy']['proxy']</td>
  <td>Proxy address for caddy</td>
  </tr>
</table>
