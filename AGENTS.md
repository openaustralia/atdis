# AGENTS.md

This file provides guidance to AI coding agents (Claude Code, GitHub Copilot,
and others) when working with code in this repository. `CLAUDE.md` and
`.github/copilot-instructions.md` point here so the guidance lives in one place.

## What this gem is

`atdis` reads and validates planning application data feeds that follow the
Application Tracking Data Interchange Specification (ATDIS). Validation is not
incidental to it: the point is to say precisely how a council's feed departs
from the specification, so the error messages are the product as much as the
parsed data is.

The specification is in the repository, under `docs/`, as both a PDF and a Word
document (ATDIS version 1.0.2). It is the source of truth for field names,
types and which fields are mandatory. Read the relevant section before changing
a model or a validation, rather than inferring the rule from the existing code
or from whichever feed you happen to be looking at.

## Layout

- `lib/atdis/model.rb` is the base class, and it carries most of the machinery:
  `field_mappings`, type casting, and the `ATDIS::ErrorMessage` struct.
- The classes in `lib/atdis/models/` are ActiveModel objects that mostly just
  declare their fields and validations, so a change tends to be a new
  declaration rather than new code. Each one has a matching spec in
  `spec/atdis/models/`; keep that pairing.
- `lib/atdis/feed.rb` fetches a feed and handles paging (`next_page`,
  `previous_page`), with `lib/atdis/separated_url.rb` supporting it.
- `lib/atdis/validators.rb` holds the validators shared between models.
- Field types are mostly `String`, `DateTime` and `URI`, but
  `Models::Location#geometry` is an `RGeo::GeoJSON` decoded by the base
  class, so geometry problems in a feed surface as cast failures there.

## Conventions worth knowing

- **Every validation cites its spec section.** Validations pass a
  `spec_section:` option (`presence_before_type_cast: { spec_section: "4.3.1" }`)
  and errors are `ATDIS::ErrorMessage` structs holding a message plus that
  section number. A new validation without a section number is an incomplete
  one, because callers use it to point people at the paragraph they have
  broken.
- **Unrecognised JSON is an error, not something to ignore.** Anything in a
  feed that no `field_mappings` declaration claims ends up in
  `json_left_overs`, which fails validation with "Unexpected parameters in json
  data". So adding support for a field means adding it to `field_mappings`, and
  a feed carrying an undeclared field is reported rather than silently dropped.
- **A timezone is required and it changes how dates are read.** `Feed.new`
  takes a timezone string (e.g. `"Sydney"`) and threads it through every model
  down to `cast_datetime`. A time in the feed that carries its own offset is
  converted to that timezone; a time without one is interpreted as being in it.
  So the same feed read with a different timezone gives different times, and
  anything you add that parses a date needs to keep honouring it.
- `presence_before_type_cast` exists because a mandatory field that is present
  but unparseable needs to report differently from one that is missing. Reach
  for it rather than plain `presence` on feed fields.
- `.rubocop.yml` disables the `Metrics/*` cops and several style cops on
  purpose, each with a comment giving the reason.
  `Style/OptionalBooleanParameter` in particular is off because turning those
  positional booleans into keyword arguments would break the public API. Don't
  re-enable a cop and then "fix" what it flags without dealing with that.

## Commands

    bundle exec rspec      # also runs as "rake spec" and the default task
    bundle exec rubocop

Both are separate CI jobs. The test job runs the matrix of Ruby 3.2, 3.3 and
3.4; the lint job runs on 3.2 only. `.ruby-version` pins 3.2.2 locally.

Unlike the other OAF gems, `spec/spec_helper.rb` sets no SimpleCov minimum
here. Coverage is collected and currently covers every line, but nothing fails
if it drops.

`Guardfile` and the Guard, growl and rb-readline development gems are for local
file-watching only. Nothing in CI uses them and you don't need them to work on
the gem.

`Gemfile.lock` is gitignored and untracked. `bundle install` changes it
locally, which is expected. Never force-add it.

## Releasing

Don't run `bundle exec rake release`. It exists only because of
`bundler/gem_tasks` and would tag and publish from your machine. Releases are
automated: the Release workflow fires when a push to `main` touches
`lib/atdis/version.rb` and publishes through RubyGems trusted publishing in the
`release` environment. Follow the README's "Releasing a new version" section.

## Org-level guidance

Workflow, branch naming, commit sign-off, AI disclosure and review conventions
are org-wide and deliberately not restated here. Fetch them when you need them:

    gh api repos/openaustralia/.github/contents/.github/CONTRIBUTING.md -H "Accept: application/vnd.github.raw"
    gh api repos/openaustralia/.github/contents/AGENTS.md -H "Accept: application/vnd.github.raw"

The README's Contributing section points people at the same guide. This
repository has no overrides of it. If one is ever agreed, record it here with
the reason, so the difference reads as a decision rather than drift.
