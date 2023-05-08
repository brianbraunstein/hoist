# Hoist Helm Library

- <https://github.com/brianbraunstein/hoist>

## Overview

This library fixes the following fundamental flaws with Helm cause by it's
values.yaml feature:
- a) Forces encapsulation violations by exposing implementation details of a
     chart by exposing subcharts and forcing the top level chart user to
     directly configure subcharts at arbitrarily nested levels.
- b) Forces DRY principle (Don't Repeat Yourself) violations by not allowing a
     single configuration option in the top level chart to fan-out to subcharts.
     (See https://github.com/helm/helm/issues/2492 which points to
     https://github.com/helm/helm/pull/6876 and other related requests)

Hoist solves both these problems by:
- Defining a convention for making Helm templates.
- Providing supporting libraries to conveniently exploit this convention.

## Status

This is currently a prototype.

## Example Usage

See <https://github.com/brianbraunstein/hoist/tree/main/examples>

## Specification

### Sails

A template library made using Hoist is called a "Sail".
More specifically, a "Sail" is the combination of 2 templates:

  Resource Definition Template:
    A template name which receives a Hoist "Sail Context" object which contains
    the following fields:
      name:
        Name to be used for Kubernetes resources created by this template.  The
        name MUST either be used directly or as a prefix.  (The docs for the
        "hoist" template describe where this name comes from).
      context:
        The standard Helm context object (with .Release, .Charts, .Values, etc)
      params:
        A map of values used to configure the resources produced by this chart
        (similar to .Values)

  Default Params Template:
    A template with the same name was the above template, except with
    ".default_params" appended to the name.
    It takes a partial "Sail Context" object containing only "name" and
    "context".  "params" isn't yet available because it's in the process of
    being built when this template is called.  As you might guess, this template
    is called first to produce the params that are then used to call the
    Resource Definition Template.

Those 2 templates completely define a Sail.

### Invoking Sails

Clients of the Sail do not call those templates directly.  Instead, clients use
the Hoist library's "hoist" or "rehoist" templates which do some magic and then
invoke the Sail's templates.

## Notes

Some additional points for clarification:
- A single Helm Library Chart can contain many Sails.
- A Helm non-library Chart can also make use of hoist, both as a client to
  already defined Sails, and to define new Sails.  Just be careful about using
  values.yaml/.Values within a Sail, as this may start to get somewhat
  confusing, and also might bring back fundamental flaw (a) from above.

Caveat:
- One unfortunate consequence is that existing chart libraries are largely
  incompatible with Hoist because they suffer from the fundamental flaws
  described above.

## Next steps / TODOs

- Consider changing the hoist context to instead be an extension of the normal
  Helm context, rather than containing it.
  - Advantages: less changes needed to existing charts.
  - Disadvantages: could potentially clash with other libraries that do the same
    thing.

