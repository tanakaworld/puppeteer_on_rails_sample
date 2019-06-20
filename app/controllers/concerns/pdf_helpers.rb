require 'securerandom'

module PdfHelpers
  extend ActiveSupport::Concern

  def render_pdf_from_template(file_name, template_path)
    data_html = render_to_string template_path, layout: 'pdf'
    FileUtils.mkdir_p(tmp_pdf_dir) unless File.exists?(tmp_pdf_dir)
    html_file_path = generate_html_from_template(data_html)
    pdf_data = generate_pdf_from_html(html_file_path)

    render_pdf_data(pdf_data, "#{file_name}.pdf")
  rescue => e
    logger.error e
  end

  private

  def tmp_pdf_dir
    "#{Rails.root}/tmp/pdf-generator"
  end

  def log_path
    ENV['RAILS_ENV'] === 'development' ? "#{tmp_pdf_dir}/app.log" : '/var/log/pdf-generator/app.log'
  end

  def generate_html_from_template(data)
    tmp_html_file = File.open("#{tmp_pdf_dir}/#{SecureRandom.hex}.html", "w")
    tmp_html_file.puts data
    tmp_html_file.close
    tmp_html_file.path
  end

  def generate_pdf_from_html(html_path)
    tmp_pdf_file = Tempfile.new("#{SecureRandom.hex}")

    system("node #{Rails.root}/pdf-generator/pdf-from-html-file.js #{html_path} #{tmp_pdf_file.path} > #{log_path} 2> #{log_path}")

    File.read(tmp_pdf_file.path)
  end

  def render_pdf_data(data, file_name)
    send_data(data, filename: file_name, type: 'application/pdf', disposition: 'inline')
  end
end
