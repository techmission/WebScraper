class NodeSequence
  def initialize(node)
    @node = node
  end
  
  def to_node_set
    node = @node
    started_sequence = false
    node_set = Nokogiri::XML::NodeSet.new(node.document)
    while node
      break if ends_sequence?(node)
      started_sequence ||= starts_sequence?(node)
      node_set << node if started_sequence
      node = node.next
    end
    node_set
  end
  
  def starts_sequence?(node)
    true
  end
  
  def ends_sequence?(node)
    false
  end
  
  def to_s
    to_node_set.to_s
  end
  
  def last
    to_node_set.last
  end
end