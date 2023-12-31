# Changelog

## 3.0.1

  - [bugfix] Reverting the breaking change of the previous version that raised on a relationship check

## 3.0.0

  - [bugfix] Having `selects` would incorrectly remove relationships that didn't match
  - [breaking] When asked for a relationship that doesn't exist it now raises an exception instead of silently returning nil

## 2.0.0

  - [bugfix] There were some nasty issues when including if the related data was `nil`
  - [breaking] Completely revamped the `links` property to use a much better interface that maps to the more popular `pagy` library


## 1.0.0

  - Initial release
