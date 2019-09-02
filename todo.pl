#!/usr/bin/env perl

## no critic

use strictures 2;

use YAML::Syck;

#my $todo = LoadFile('todo.yaml');
#
#use Data::Dumper;
#print Dumper $todo;

my $todo = {
  'support' => {
    'resource-packs' => undef,

    'texture-packs' => {
      'base url' => 'https://www.curseforge.com/minecraft/texture-packs',
      'eval'     => 'd-creatorcraft'
    },

    'customization' => {
      'eval'     => 'eight-stairs more-logical-craft wool-into-string quark-information craftingplus better-recipes',
      'base url' => 'https://www.curseforge.com/minecraft/customization'
    },

    'addons' => {
      'eval'     => 'minecraft-font',
      'base url' => 'https://www.curseforge.com/minecraft/mc-addons'
    }
  },

  'function' => [
    'remove mods not in config file (with option to ignore mods like optifine)',
  ],

  'commands' => {
    add    => 'add mod',
    remove => 'remove mod',
  },
};

DumpFile( 'todo.yaml', $todo );
