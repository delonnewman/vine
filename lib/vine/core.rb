require 'prawn'
require 'rqrcode'
require 'tempfile'

QR_SIZE      = 150
CARD_HEIGHT  = QR_SIZE * 1.38
CARD_WIDTH   = QR_SIZE
CARD_PADDING = 40

module Vine
  module Core
    def qr_code(url)
      qr = RQRCode::QRCode.new(url)
      qr.as_png(
        bit_depth: 1,
        border_modules: 1,
        color_mode: ChunkyPNG::COLOR_GRAYSCALE,
        color: 'black',
        file: nil,
        fill: 'white',
        module_px_size: 6,
        resize_exactly_to: false,
        resize_gte_to: false,
        size: 600
      )
    end
    
    def spit(data)
      file = Tempfile.new(['qr-code-', '.png'])
    
      begin
        file.write(data.to_s)
        file.close
      rescue => e
        puts "There was an error writing to #{file.path}: #{e.message}"
        file.unlink
        raise e
      end
    
      file
    end

    def card_sheet(params)
      url     = params.fetch(:url)
      message = params[:message]
  
      pdf    = Prawn::Document.new
      height = card_height(message)

      pdf.text url, size: 10
      pdf.move_down 10

      pdf.create_stamp('card') do
        pdf.bounding_box([0, pdf.cursor], width: CARD_WIDTH, height: height) do
          if message.present?
            pdf.move_down 5
            pdf.text_box(message, at: [8, pdf.cursor - 5], width: CARD_WIDTH - 13.119, height: 50, overflow: :shrink_to_fit, min_font_size: 8)
            pdf.move_down 5
          end
          img_y  = message.blank? ? pdf.cursor : pdf.cursor - 45
          pdf.image(spit(qr_code(url)).path, at: [0, img_y], fit: [QR_SIZE, QR_SIZE])
          pdf.transparent(0.5) { pdf.stroke_bounds }
        end
      end
    
      stamp_cards(pdf, height)
    
      pdf.render
    end

    private

    def card_height(message)
      return QR_SIZE if message.blank?

      CARD_HEIGHT
    end
    
    def stamp_cards(pdf, height)
      rows = height == QR_SIZE ? 3 : 2
      (0..rows).each do |row|
        (0..2).each do |col|
          pdf.stamp_at 'card', [(CARD_WIDTH + CARD_PADDING) * col, ((height + CARD_PADDING) * row) * -1]
        end
      end
    end

    module_function :stamp_cards, :card_sheet, :spit, :qr_code
  end
end
