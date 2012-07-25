module SpreadsheetOnRails

  def self.render_xls_string(spreadsheet, template = nil)
<<RENDER
    if template.nil?
      workbook = Spreadsheet::Workbook.new
    else
      book = Spreadsheet.open("Rails.root/spreadsheet_templates/#{spreadsheet_template}")
    end
    #{spreadsheet}
    blob = StringIO.new("")
    workbook.write(blob)
    blob.string
RENDER
  end

end

# Setups the template handling
require "action_view/template"
require 'spreadsheet'
ActionView::Template.register_template_handler :rxls, lambda { |template|
  SpreadsheetOnRails.render_xls_string(template.source, spreadsheet_template)
}

# Why doesn't the aboce template handler catch this one as well?
# Added for backwards compatibility.
ActionView::Template.register_template_handler :"xls.rxls", lambda { |template|
  SpreadsheetOnRails.render_xls_string(template.source, spreadsheet_template)
}

# Adds support for `format.xls`
require "action_controller"
Mime::Type.register "application/xls", :xls

ActionController::Renderers.add :xls do |filename, options|
  send_data(render_to_string(options), :filename => "#{filename}.xls", :type => "application/xls", :disposition => "attachment")
end
