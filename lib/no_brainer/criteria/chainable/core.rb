module NoBrainer::Criteria::Chainable::Core
  extend ActiveSupport::Concern

  included { attr_accessor :init_options }

  def initialize(options={})
    self.init_options = options
  end

  def klass
    init_options[:klass]
  end

  def to_rql
    with_default_scope_applied.__send__(:compile_rql_pass2)
  end

  def inspect
    # rescue super because sometimes klass is not set.
    str = to_rql.inspect rescue super
    if str =~ /Erroneous_Portion_Constructed/
      # Need to fix the rethinkdb gem.
      str = "the rethinkdb gem is flipping out with Erroneous_Portion_Constructed"
    end
    str
  end

  def run(rql=nil)
    NoBrainer.run(rql || to_rql)
  end

  def merge!(criteria, options={})
    self.init_options = self.init_options.merge(criteria.init_options)
    self
  end

  def merge(criteria, options={})
    dup.tap { |new_criteria| new_criteria.merge!(criteria, options) }
  end

  def ==(other)
    return super if other.is_a?(NoBrainer::Criteria)
    return to_a == other if other.is_a?(Enumerable) && other.first.is_a?(NoBrainer::Document)
    super
  end

  private

  def chain(options={}, &block)
    tmp = self.class.new(self.init_options) # we might want to optimize that thing
    block.call(tmp)
    merge(tmp, options)
  end

  def compile_rql_pass1
    # This method is overriden by other modules.
    raise "Criteria not bound to a class" unless klass
    klass.rql_table
  end

  def compile_rql_pass2
    # This method is overriden by other modules.
    compile_rql_pass1
  end
end
