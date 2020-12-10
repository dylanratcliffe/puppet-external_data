# external_data

This module acts as a multiplexer and cache for the [trusted external data](https://tickets.puppetlabs.com/browse/PUP-9994) feature of Puppet. This module execute "foragers" to gather data and stores it in a cache, both of which are pluggable

## Using This Module

In order to enable this integration, classify all Masters and Compilers with the `external_data` class and then configure:

* **The cache:** This will be used to store data, the recommended cache is `disk` which caches data to a directory on the local filesystem
* **The Foragers:** This module doesn't contain any foragers, you will have to get those from other modules that are designed to work with this one. You can have as many forager as you like and they will be executed as required to gather external data about your nodes

```puppet
class { 'external_data':
  config => {
    'cache'    => {
      'name'    => 'disk',
      'options' => {
        'path' => '/opt/puppetlabs/cache', # Remeber to create this directory
      },
    },
    'foragers' => [
      {
        'name'    => 'example',
        'options' => {
          'colour' => 'red',
        }
      }
    ]
  },
  notify => Service['pe-puppetserver'],
}
```

## Caches

### `disk`

This uses the local disk to store cached data in JSON files under a given directory, it is the simplest form of cache and is fairly performant, but lacks any form of synchronization meaning that if you have many compilers or masters, each will maintain its own cache, increasing the workload for whatever the foragers are hitting.

#### Options

`path`: The path on disk where files should be stored. This needs to exist and should be writable by the user which the puppetserver runs as.

### `none`

This simply doesn't cache. Any foragers that are designed to use a cache, won't. Any `:batch` foragers will not be able to store their data anywhere and will therefore not work. This was only really created for testing and I can't imagine many uses for it.

#### Options

This cache has no options.

## Foragers

There are some options that apply to all foragers:

`min_age`: The minimum age for a record in seconds, if records are older younger than this the forager will not be executed at all and the cache will be used.

## Writing Foragers

[Example Forager](https://github.com/dylanratcliffe/puppet-external_data/blob/master/lib/puppet_x/external_data/forager/example.rb)

Foragers are the most interesting part of this module, they are used for getting information about nodes from external sources, the following types of foragers are available

### Types

#### `:ondemand`

On Demand foragers execute each time the catalog is compiled for a particular host. This assumes that the API we are interacting with doesn't have any way of checking for records that have been updated since a certain time. If combined with `min_age` this allows for a very simple way of creating integrations as each record will be cached until it reaches its `min_age`, then it will be looked up the next time the node checks in., the cache will be used in the meantime. If `min_age` is not set then these won't be cached at all.

#### `:ondemand_cached`

Similar to an `:ondemand` forager except that it is able to receive an empty response from whatever this is querying and treat this as "The data has not changed" in which case the previous data for that node will be returned. These backends will also need to be able to receive a response that means "There is no data here" in which case the cache for that node will need to be cleared and nothing returned to the puppetserver

#### `:batch`

Batch foragers will always return cached data on catalog compiles as they only do updates in batches. **This has yet to be implemented**

### Required Methods

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

#### Using Metadata

Foragers have a `metadata` method which can be used to store metadata such as the last updated time. It acts like a hash but stores data in the cache and can be accessed like so:

```ruby
if metadata["#{certname}-LastUpdated"] > 1
  # Do something
end
```

Note that it is recommended to only use string keys.

#### Using Facts

Foragers have a `pdb_get_fact` method which can be used to query PuppetDB for a fact present for the given node.

**Note:** This will always return `nil` the first time a node checks in since PuppetDB won't have any information about the node until after the first agent run.

Dot notation is supported for specifing structured facts. For example:

```ruby
pdb_get_fact(certname, 'os.release')
```

Would return `{"full"=>"7.6.1810", "major"=>"7", "minor"=>"6"}` when a nodes `os` fact is:
```ruby
{"name"=>"CentOS", "family"=>"RedHat", "release"=>{"full"=>"7.6.1810", "major"=>"7", "minor"=>"6"}, "selinux"=>{"enabled"=>true, "enforced"=>true, "config_mode"=>"enforcing", "current_mode"=>"enforcing", "config_policy"=>"targeted", "policy_version"=>"31"}, "hardware"=>"x86_64", "architecture"=>"x86_64"}
```


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
