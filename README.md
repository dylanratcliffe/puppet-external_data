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

