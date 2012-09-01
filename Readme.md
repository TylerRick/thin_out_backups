# thin_out_backups

Quickly and safely thin out a backups directory that's taking up too much hard disk space!

`thin_out_backups` will keep the specified number of backups in each frequency category (weekely,
daily, etc.) and delete the rest, keep the space requirements of your backups directory fairly
constant over time. 

The files that you are thinning out don't have to be backups, but that is probably the most common
use case.

## Installation

    $ gem install thin_out_backups

## Usage

    $ thin_out_backups



## License

Copyright 2008, 2012 Tyler Rick

Released under the MIT license. See License file.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Other names considered

* thin_out_backup_dir
* sparsen_dir
* sparsify_dir
* rm_extra_copies
* prune_backups
* trim_dir
