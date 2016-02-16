# 03-vagrant module

#### Required Software
- [VMware Fusion](https://www.vmware.com/products/fusion/fusion-evaluation)
- [Packer](https://www.packer.io/downloads.html)
- [Vagrant](https://www.vagrantup.com/downloads.html)
- [Vagrant VMware Provider Plugin](https://www.vagrantup.com/docs/vmware/installation.html)

#### Build Vagrant Boxes

  1. Download `CentOS-7-x86_64-DVD-1511.iso` from a trusted source.  Create the `iso` directory inside the `03-vagrant` module.  Put the ISO file under the `iso` directory.

  2. Build the `consul-server` Vagrant box.

  ```
  $ packer build packer-templates/consul-server.json
  ```

  3. Add the `consul-server` Vagrant box.

  ```
  $ vagrant box add builds/consul-server.vmware.box --name consul-server
  ```

  4. Build the `web-server` Vagrant box.

  ```
  $ packer build packer-templates/web-server.json
  ```

  5. Add the `web-server` Vagrant box.

  ```
  $ vagrant box add builds/web-server.vmware.box --name web-server
  ```

  6. Build the `haproxy` Vagrant box.

  ```
  $ packer build packer-templates/haproxy.json
  ```

  7. Add the `haproxy` Vagrant box.

  ```
  $ vagrant box add builds/haproxy.vmware.box --name haproxy
  ```

  8. Set two environment variables.

  ```
  $ export ATLAS_ENVIRONMENT=<your_atlas_environment>
  
  $ export ATLAS_TOKEN=<your_atlas_token>
  ```

#### Launch the `consul-server` Vagrant Machines

  1. The included `Vagrantfile` under the `vagrantfiles/consul-server` directory will spin up three Consul servers locally.

  ```
  $ cd vagrantfiles/consul-server; vagrant up; cd ../..
  ```

#### Create the `web-server` Vagrant Machines

  1. The included `Vagrantfile` under the `vagrantfiles/web-server` directory will spin up two web servers locally.

  ```
  $ cd vagrantfiles/web-server; vagrant up; cd ../..
  ```

#### Create the `haproxy` Vagrant Machine

  1. The included `Vagrantfile` under the `vagrantfiles/haproxy` directory will spin up one HAProxy server locally.

  ```
  $ cd vagrantfiles/haproxy; vagrant up; cd ../..
  ```
