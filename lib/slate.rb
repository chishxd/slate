# frozen_string_literal: true

require_relative "slate/version"
require "kramdown"
require 'kramdown-parser-gfm'

module Slate
  class Error < StandardError; end
  class CLI
    # This method is the MAIN method... Refactored from bin/slate
    def self.run(path)
      path = File.expand_path(path)
      if File.file?(path)
        process_file(path)
      elsif File.directory?(path)
        process_directory(path)
      else
        puts "Error: #{path} Is neither a file, nor a directory"
      end
    end

    def self.convert(md_content, title)
      raw_html = Kramdown::Document.new(md_content, input: 'GFM').to_html

      final_html = "<head>\n<title> #{title} </title> <link href='style.css' rel='stylesheet'></head><body class='markdown-body'>\n#{raw_html}\n</body>"

      return final_html
    end

    def self.process_file(path)
      puts "Argument seems to be a single file, Parsing it"
      content = File.read(path)
      filename = File.basename(path, ".*")
      dir = File.dirname(path)
  
      style_path = File.join(__dir__, '..', 'style.css')
      FileUtils.cp(style_path, dir)
      
      final_html = convert(content, filename)
      output_path = File.join(path, "#{filename}.html")
      File.write(output_path, final_html)
      puts "Saved #{filename}.html"
    end

    def self.process_directory(path)
      puts "Found a directory, gotta check all .md files!"

      style_path = File.join(__dir__, '..', 'style.css')
      FileUtils.cp(style_path, path)
  
      files = Dir.glob(File.join(path, "*.md"))
      files.each do |file|
        content = File.read(file)
        filename = File.basename(file, ".*")    
        final_html = convert(content, file)
        output_path = File.join(path, "#{filename}.html")
        File.write(output_path, final_html)
        puts "Saved #{filename}.html"
      end
    end

  end
end
