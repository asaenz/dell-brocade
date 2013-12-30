require 'puppet/provider/brocade_fos'
require 'puppet/provider/brocade_responses'
require 'puppet/provider/brocade_messages'

Puppet::Type.type(:brocade_alias_membership).provide(:brocade_alias_membership, :parent => Puppet::Provider::Brocade_fos) do
  @doc = "Manage brocade alias members addition and removal."

 mk_resource_methods


 def create
    Puppet.debug(Puppet::Provider::Brocade_messages::ALIAS_MEMBERSHIP_CREATE_DEBUG%[@resource[:member],@resource[:alias_name]])
    response = @transport.command("aliadd #{@resource[:alias_name]}, \"#{@resource[:member]}\"", :noop => false)
	if ( response.include? Puppet::Provider::Brocade_responses::RESPONSE_NOT_FOUND ) || ( response.include? Puppet::Provider::Brocade_responses::RESPONSE_INVALID) 
      raise Puppet::Error, Puppet::Provider::Brocade_messages::ALIAS_MEMBERSHIP_CREATE_ERROR%[@resource[:member],@resource[:alias_name],response]
    elsif response.include? Puppet::Provider::Brocade_responses::RESPONSE_ALREADY_CONTAINS
      Puppet.info(Puppet::Provider::Brocade_messages::ALIAS_MEMBERSHIP_ALREADY_EXIST_INFO%[@resource[:member],@resource[:alias_name]])
    else
      cfg_save
    end
  end

  def destroy
    Puppet.debug(Puppet::Provider::Brocade_messages::ALIAS_MEMBERSHIP_DESTROY_DEBUG%[@resource[:member],@resource[:alias_name]])
    response =  @transport.command("aliremove #{@resource[:alias_name]},\"#{@resource[:member]}\"", :noop => false)
    if ( response.include? Puppet::Provider::Brocade_responses::RESPONSE_DOES_NOT_EXIST)
      raise Puppet::Error, Puppet::Provider::Brocade_responses::ALIAS_MEMBERSHIP_DESTROY_ERROR%[@resource[:member],@resource[:alias_name],response]
	elsif (response.include? Puppet::Provider::Brocade_responses::RESPONSE_IS_NOT_IN )
	  Puppet.info(Puppet::Provider::Brocade_messages::ALIAS_MEMBERSHIP_ALREADY_REMOVED_INFO%[@resource[:member],@resource[:alias_name]])
    else 
      cfg_save
	end
  end

  def exists?
    self.device_transport
    if "#{@resource[:ensure]}" == "present" 
      false
    else
      true
    end
  end

end

