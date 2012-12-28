
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Log HTTP::Tiny with Log::Any",
  "dist_author" => [
    "Steven Haryanto <stevenharyanto\@gmail.com>"
  ],
  "dist_name" => "HTTP-Tiny-Patch-LogAny",
  "dist_version" => "0.01",
  "license" => "perl",
  "module_name" => "HTTP::Tiny::Patch::LogAny",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "HTTP::Tiny" => "0.025",
    "Log::Any" => 0,
    "Module::Patch" => "0.12",
    "perl" => "5.010001"
  },
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
