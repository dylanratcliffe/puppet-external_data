# external_data

This module acts as a multiplexer and cache for the [trusted external data](https://tickets.puppetlabs.com/browse/PUP-9994) feature of Puppet. This module execute "foragers" to gather data and stores it in a cache, both of which are pluggable

## Foragers

Foragers are the most interesting part of this module, they are used for getting information about nodes from external sources, the following types of foragers are available:

### `:ondemand`

On Demand foragers execute each time the catalog is compiled for a particular host. They do no caching and should only be used when a very high performance backend is in place

### `:ondemand_cached`

Similar to an `:ondemand` forager except that it is able to receive an empty response from whatever this is querying and treat this as "The data has not changed" in which case the previous data for that node will be returned. These backends will also need to be able to receive a response that means "There is no data here" in which case the cache for that node will need to be cleared and nothing returned to the puppetserver

### `:batch`

Batch foragers will always return cached data on catalog compiles as they only do updates in batches. **This has yet to be implemented**

### Writing Foragers

[Example Forager](https://github.com/dylanratcliffe/puppet-external_data/blob/master/lib/puppet_x/external_data/forager/example.rb)

Foragers must implement the following methods:

#### `type`

This should return the type of the forager, this needs to be one of the following:

* `:ondemand`
* `:ondemand_cached`
* `:batch`

This affects how the results of this forager will be treated (if it will be cached)

#### `get_data(certname)`

This will be called when a node checks in, with the certname passed in a string. It should return a hash of data relevant to that node. In the case of an `:ondemand_cached` backend it could also return `nil`, which would mean that the latest cached data should be used. If you want to explicitly return nothing, like of the node's data has been deleted, return an empty hash `{}`

#### `name`

This should return the name of the forager.

### Writing Caches

[Example Cache](https://github.com/dylanratcliffe/puppet-external_data/blob/master/lib/puppet_x/external_data/cache/disk.rb)

Caches are responsible for storing data persistently. They have a set of methods that they need to implement which will be detailed below.

#### `self.name`

The name of the cache, this is what is used in the config file

#### `_get(forager, certname)`

* `forager`: The name of the forager which is getting its data
* `certname`: The certname of the machine we are requesting for

This should return a hash of data for the requested node. Note that caches should be able to store data for each forager somewhat separately as there is guarantee that one forager won't hav keys that clash with another for a given host.

#### `_delete(forager, certname)`

* `forager`: The name of the forager which is deleting its data
* `certname`: The certname of the machine we are requesting for

This should delete the data for a given forager & certname combo. The return value is discarded.

#### `_update(forager, certname, data)

* `forager`: The name of the forager which is updating its data
* `certname`: The certname of the machine we are requesting for
* `data`: The hash of data to store

The cache should persist the given data.

## Development

Before running any tests, install the gems:

```shell
bundle install
```

Run the spec tests:

```shell
bundle exec rake spec
```

Provision the acceptance testing environment:

```shell
bundle exec rake 'litmus:provision_list[docker]'
```

Install the module:

```shell
bundle exec rake 'litmus:install_module'
```

Run acceptance tests:

```shell
bundle exec rake 'litmus:acceptance:parallel'
```