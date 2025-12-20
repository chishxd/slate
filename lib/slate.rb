# frozen_string_literal: true

require_relative "slate/version"
require "kramdown"

module Slate
  class Error < StandardError; end
  def self.convert(md_content, title)
    raw_html = Kramdown::Document.new(md_content).to_html

    final_html = "<head>\n<title> #{title} </title> <link href='style.css' rel='stylesheet'></head><body class='markdown-body'>\n#{raw_html}\n</body>"

    return final_html
  end
end
