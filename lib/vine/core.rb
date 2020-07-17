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
      message = params.fetch(:message)
  
      pdf = Prawn::Document.new
    
      pdf.create_stamp('card') do
        pdf.bounding_box([0, pdf.cursor], width: CARD_WIDTH, height: CARD_HEIGHT) do
          pdf.move_down 5
          pdf.text_box(message, at: [8, pdf.cursor - 5], width: CARD_WIDTH - 13.119, height: 50, overflow: :shrink_to_fit, min_font_size: 8)
          pdf.move_down 5
          pdf.image(spit(qr_code(url)).path, at: [0, pdf.cursor - 45], fit: [QR_SIZE, QR_SIZE])
          pdf.transparent(0.5) { pdf.stroke_bounds }
        end
      end
    
      stamp_cards(pdf)
    
      pdf.render
    end

    private

    def stamp_cards(pdf)
      (0..2).each do |m|
        (0..2).each do |n|
          pdf.stamp_at 'card', [(CARD_WIDTH + CARD_PADDING) * n, ((CARD_HEIGHT + CARD_PADDING) * m) * -1]
        end
      end
    end

    module_function :stamp_cards, :card_sheet, :spit, :qr_code
  end
end
