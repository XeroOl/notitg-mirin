-- check template/core/init.lua for the function `scan_named_actors`
-- Normally, when you require 'mirin.actors', you get the table from scan_named_actors
-- This file only gets loaded if you require it too early in the load order
error('You have required this file too early. Please wait until OnCommand')
