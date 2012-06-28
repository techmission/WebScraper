module HTMLCleaning
 
  def self.clean(html, options={})
    tidy = options[:tidy]
    tidy = true if tidy.nil?
    
    convert_to_plain_text = options[:convert_to_plain_text]
    convert_to_plain_text = false if convert_to_plain_text.nil?
    
    html = tidy(html) if tidy
    html = convert_to_plain_text(html) if convert_to_plain_text
    html
  end
  
  def self.tidy(html)
    return html  
  end
  
  def self.convert_to_plain_text(html)
    convert_node_to_plain_text(Nokogiri::HTML(html)).strip.gsub(/[ \t\r\f]*\n/, "\n").gsub(/\n[ \t\r\f]*/, "\n").gsub(/\n{3,}/, "\n\n")
  end
  
  private
    def self.convert_node_to_plain_text(node)
      pre(node) + 
      (node.children.empty? ? leaf(node) : node.children.to_ary.map{|child| convert_node_to_plain_text(child)}.join("")) + 
      post(node)
    end
    
    def self.pre(node)
      case node.name
      when "li"
        "\n * "
      else
        ""
      end
    end
    
    def self.post(node)
      case node.name
      when "p", "h1", "h2", "h3", "h4", "h5", "div"
        "\n\n"
      else
        ""
      end
    end
    
    def self.leaf(node)
      case node.name
      when "comment"
        ""
      when "br"
        "\n"
      else
        node.text ? node.text.gsub(/\n/, " ") : ""
      end
    end
end