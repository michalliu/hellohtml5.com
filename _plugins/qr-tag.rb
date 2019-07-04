require 'rqrcode_png'

#https://github.com/sectore/jekyll-swfobject/blob/master/lib/jekyll-swfobject.rb
#https://jekyllrb.com/docs/plugins/your-first-plugin/
module Jekyll
    class QrCodeTag < Liquid::Tag
        @@DEFAULTS = {
            :fill => 'white',
            :color => '000',
            :size => '120',
            :module_size => '4',
            :offset => '0',
            :type => 'png'
        }

        def self.DEFAULTS
            return @@DEFAULTS
        end

        def initialize(tag_name, markup, tokens)
            super
            
            #config
            @config = {}

            #set defaults
            override_config(@@DEFAULTS)
            
            #url which supports expression
            @url_component = []

            params = markup.split
            if params.size > 0
                config = {} # reset local config
                params.each do |param|
                    param = param.gsub /\s+/, '' # remove whitespace
                    if param[0] == '`' and param[-1] == '`' # variable
                        @url_component.push param
                    elsif param.include? ':' # options
                        key, value = param.split(':', 2) # split first occurrence of ':' only
                        config[key.to_sym] = value
                    else # raw string
                        @url_component.push param
                    end
                end
                override_config(config)
            end
        end

        def override_config(config)
            config.each{ |key, value| @config[key] = value }
        end

        def get_value(context, expression)
            if (expression[0] == '`' and expression[-1] == '`')
                var = expression[1..-2]
                lookup_path = var.split('.')
                result = context
                lookup_path.each do |variable|
                    result = result[variable] if result
                end
                return result
            end
            return expression
        end
        
        def get_url(context)
            url = []
            @url_component.each do |comp|
                url.push get_value(context, comp)
            end
            return url.join
        end

        def render(context)
            qr = RQRCode::QRCode.new(get_url(context))
            case @config[:type]
            when "s"
                data = qr.to_s(
                    fill: @config[:fill],
                    color: @config[:color],
                    size: Integer(@config[:size])
                )
                tag = "pre"
            when "svg"
                data = qr.as_svg(
                    offset: Integer(@config[:offset]),
                    fill: @config[:fill],
                    color: @config[:color],
                    module_size: Integer(@config[:module_size]),
                )
                tag = "svg"

            else
                data = qr.as_png(
                    offset: Integer(@config[:offset]),
                    fill: @config[:fill],
                    color: @config[:color],
                    size: Integer(@config[:size]),
                    module_size: Integer(@config[:module_size]),
                )
                tag = "img"
            end

            case tag
            when "pre"
                "<pre>#{data}</pre>"
            when "svg"
                "#{data}"
            when "img"
                "<img src=\"#{data.to_data_url}\" alt=\"#{get_url(context)}\"/>"
            end
        end
        Liquid::Template.register_tag 'qrcode', self
    end
end