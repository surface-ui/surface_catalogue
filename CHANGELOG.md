# Changelog

## v0.6.3 (yyyy-mm-dd)

* Remove dependency on Surface Forms (#56)

## v0.6.2 (2024-02-20)

* Fix bug when dispatching events creared the slot value
* Fix warnings related to using variables inside Liveview templates

## v0.6.1 (2023-06-21)

* Support Surface `v0.11`
* Make `plug_cowboy` optional (#50)

## v0.6.0 (2023-04-18)

* Support Surface `v0.10` and Liveview `v0.18.8`

## v0.5.2 (2022-09-23)

* Support Surface `v0.9` and Liveview `v0.18`

## v0.5.1 (2022-09-08)

* Fix application depending on `Mix`

## v0.5.0 (2022-09-01)

* Support Surface `v0.8.0`
* Support multiple examples on a single module (#43)
* Add slots tab to the playground tools (#42)
* Handle `:number` values in playground inputs
* Display values from the `values!` option
* Add arguments on public API slot section (#37)
* Show error message for invalid props (#39)

## v0.4.1 (2022-03-21)

* Upgrade to earmark 1.4.23, earmark_parser 1.4.24
* Stop passing `smartypants` to Earmark
* Fix deprecation warnings crashing catalogue

## v0.4.0 (2022-03-14)

* Use a separate esbuild configuration to build the catalogue app's assets
* Fix JS incompatibility with Liveview >= v0.17.6 (#31)

## v0.3.0 (2022-01-13)

* Update Surface to v0.7

## v0.2.0 (2021-10-21)

* Update Surface to v0.6

## v0.1.0 (2021-06-17)

* Update Surface to v0.5
* Add sample catalogue

## v0.0.9 (2021-06-04)

* Fix updating example code when switching from one example to another (#14)

## v0.0.8 (2021-05-01)

* Update to Surface v0.4.0
* Support for single catalogue
* Support setting title and subtitle from config
* Add scrolling to example config, dynamic scrolling setting on iframe (#10)

## v0.0.7 (2021-02-24)

* Allow setting `nil` for integer and lists in the prop editor
* Allow setting `nil` for props with predefined values in the prop editor
* Fix default prop values getting cleared after updating props in the prop editor
* Fix sorting list of examples

## v0.0.6 (2021-02-18)

* Allow setting `nil` in the prop editor of the playground

## v0.0.5 (2021-02-12)

* Only log events of the playgrouns's subject
* Fix feedback of pending events

## v0.0.4 (2021-02-11)

* Show description for each example based on its `@moduledoc`

## v0.0.3 (2021-02-05)

* Allow inspect assigns/state of live components
* More consistent tracing of live components state changes

## v0.0.2 (2021-02-03)

* Define a default ErrowView for the server endpoint
* Fix boolean input when default is true
* Fix public functions listing in API
* Loading feedback for playgrounds

## v0.0.1 (2021-02-01)

* Initial prototype
