<!--
SPDX-FileCopyrightText: 2023 Fermi Research Alliance, LLC
SPDX-License-Identifier: Apache-2.0
-->

# Scripts

Collection of custom scripts that can be used in the Frontend, or Factory, or as jobs started bi the Glidein.

The custom scrips, added to the Factory or Frontend configuration and executed by the Glidein, follow the standards described in the
[Cusrom Scripts documentation](https://glideinwms.fnal.gov/doc.prd/factory/custom_scripts.html). In short:

- they expect to receive the path to `glidein_config` as argument
- they should end invoking `error_gen` to state failure or successful termination

A comment line within the first 10 lines is expected to start with `#GWNS-CS` and have space separated key:value pairs according to the following options:

- specify where this script can be used. Keyword: `file:`, value: comma separated list of `factory`, `frontend`, `standalone`, default: `frontend,factory`

Future keywords will help define the file entry in the Fcatory or Frontend.


Most code is distributed under the Apache 2.0 license, see header of the individual scripts, the LICENSE file and the LICANSES directory.
If you are contributing code please follow REUSE to specify the license, by default Apache 2.0.

This project has a pre-commit config.
To install it run `pre-commit install` from the repository root.
You may want to setup automatic notifications for pre-commit enabled
repos: https://pre-commit.com/index.html#automatically-enabling-pre-commit-on-repositories
You can run manually pre-commit:

```shell
pre-commit run --all-files
```
