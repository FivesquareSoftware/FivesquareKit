#!/usr/bin/env ruby

#
#	 momd-rule.rb
#	 FivesquareKit
#
#	 Created by John Clayton on 4/05/2012.
#	 Copyright 2012 Fivesquare Software, LLC. All rights reserved.
#


require 'rubygems'
require 'optparse'
require 'ostruct'

ROOT_DIR = File.dirname(__FILE__)

class MomDRule
		
	attr_accessor :options
	
	def self.execute!
		new.execute!
	end
	
	def execute!
		parse_opts!
		generate
		compile
	end



	#----------------------------------------------------------------------------
	private
	
	
	## Actions
	
	def parse_opts!
		self.options = OpenStruct.new
				
		# Default options, can be overridden by what's in command line opts
		self.options.model = input_file_path
		self.options.plist_buddy = '/usr/libexec/PlistBuddy'
		self.options.mogenerator = File.join(ROOT_DIR,'bin/mogenerator')
		self.options.template_path = File.join(ROOT_DIR,'templates')
		self.options.output_dir = input_file_dir
		self.options.human_dir = File.join(self.options.output_dir,'Human')
		self.options.machine_dir = File.join(self.options.output_dir,'Machine')
		self.options.base_class = nil
		self.options.base_class_import = ""
		self.options.use_arc = true
		self.options.includeh = File.join(self.options.human_dir,"#{input_file_base}Model.h")
		self.options.momc = "#{ENV['SYSTEM_DEVELOPER_BIN_DIR']}/momc"
		self.options.verbose = false
		

		opts = OptionParser.new do |opts|
			opts.banner = "Usage: #{$0} [options]"
			opts.on("-m", "--model MODEL", "The path to the modeld file. By default, will attempt to use the environment to figure this out: INPUT_FILE_PATH then SCRIPT_INPUT_FILE_0.") do |opt|
				self.options.plist_buddy = opt
			end
			opts.on("-p", "--plist-buddy PLISTBUDDY", "The path to PlistBuddy. Defaults to #{self.options.plist_buddy}.") do |opt|
				self.options.plist_buddy = opt
			end
			opts.on("-g", "--mogenerator MOGENERATOR", "The path to mogenerator. Defaults to #{self.options.mogenerator}.") do |opt|
				self.options.mogenerator = opt
			end
			opts.on("-t", "--template-path TEMPLATEPATH", "The path to mogenerator templates. Defaults to #{self.options.template_path}.") do |opt|
				self.options.template_path = opt
			end
			opts.on("-o", "--output-dir OUTPUTDIR", "The base directory mogenerator will output source files to. Defaults to #{self.options.output_dir}.") do |opt|
				self.options.output_dir = opt
			end
			opts.on("-u", "--human-dir HUMANDIR", "The path mogenerator will output human editable source files to. Defaults to #{self.options.human_dir}.") do |opt|
				self.options.human_dir = opt
			end
			opts.on("-x", "--machine-dir MACHINEDIR", "The path mogenerator will output machine generated source files to. Defaults to #{self.options.machine_dir}.") do |opt|
				self.options.machine_dir = opt
			end
			opts.on("-b", "--base-class BASECLASS", "The base class to pass to mogenerator. Defaults to empty, which results in NSManagedObject being used.") do |opt|
				self.options.base_class = opt
			end
			opts.on("-i", "--base-class-import TEXT", "Import base class as TEXT. Defaults to empty, which results in #import BaseClass.h being used.") do |opt|
				self.options.base_class_import = opt
			end
			opts.on("-r", "--use-arc", "Generate ARC compatible code. Defaults to true.") do |opt|
				self.options.use_arc = true
			end
			opts.on("-c", "--momc MOMC", "The path to momc. Defaults to #{self.options.momc}.") do |opt|
				self.options.plist_buddy = opt
			end
			opts.on("-v", "--verbose", "Generate verbose output. Defaults to false.") do |opt|
				self.options.verbose = true
			end
		end
		opts.parse!
	end
	
	def generate
		log self.options.inspect
		log "Generating source files from model version: #{current_version_name}"
		base_class_opt = self.options.base_class ? "--base-class #{self.options.base_class}" : ""
		arc_template_opt = self.options.use_arc ? "--template-var arc=true" : ""
		cmd = %Q{"#{self.options.mogenerator}" --model "#{current_model_path}" --template-path "#{self.options.template_path}" --machine-dir "#{self.options.machine_dir}" --human-dir "#{self.options.human_dir}" #{base_class_opt} --base-class-import "#{self.options.base_class_import}" #{arc_template_opt}}
		log cmd
		output = `#{cmd}`
		error "Couldn't generate source files: #{output}" unless $? == 0
		log output
	end

	def compile
		# not right now
	end

	## Helpers
	
	def input_file_path
		if @input_file_path == nil
			@input_file_path = ENV['INPUT_FILE_PATH'] || ENV['SCRIPT_INPUT_FILE_0']
		end
		log "@input_file_path: #{@input_file_path}"
		@input_file_path
	end
	
	def input_file_dir
		if @input_file_dir == nil
			@input_file_dir =	 ENV['INPUT_FILE_DIR'] || File.dirname(input_file_path)
		end
		# log "@input_file_dir: #{@input_file_dir}"
	 @input_file_dir
	end
	
	def input_file_base
		if @input_file_base == nil
			@input_file_base = ENV['INPUT_FILE_BASE'] || File.basename(input_file_path,'.xcdatamodeld')
		end
		# log "@input_file_base: #{@input_file_base}"
		@input_file_base
	end
	
	def current_version_file
		log "current_version_file: #{File.join(input_file_path,'.xccurrentversion')}"
		File.join(input_file_path,'.xccurrentversion')
	end
	
	def current_version_name
		if @current_version_name == nil && File.exist?(current_version_file)
			cmd = "#{self.options.plist_buddy} -c 'print _XCCurrentVersionName' '#{current_version_file}'"
			# log "#{cmd}"
			output = `#{cmd}`
			error "Couldn't get current model version: #{output}" unless $? == 0
			@current_version_name = output.chomp
		else
			@current_version_name = "#{input_file_base}.xcdatamodel"
		end
		log "@current_version_name: #{@current_version_name}"
		@current_version_name
	end
	
	def current_model_path
		log "current_model_path: #{File.join(input_file_path,current_version_name)}"
		File.join(input_file_path,current_version_name)
	end

	def error(msg='')
		puts "Error: >>> #{msg}"
		exit 1
	end
	
	def log(msg)
		if self.options.verbose
			puts ">>> #{msg}"
		end
	end
	
end


MomDRule.execute!


