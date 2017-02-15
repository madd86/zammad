# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/

class LinksController < ApplicationController
  prepend_before_action :authentication_check

  # GET /api/v1/links
  def index
    links = Link.list(
      link_object: params[:link_object],
      link_object_value: params[:link_object_value],
    )

    assets = {}
    link_list = []
    links.each { |item|
      link_list.push item
      if item['link_object'] == 'Ticket'
        ticket = Ticket.lookup( id: item['link_object_value'] )
        assets = ticket.assets(assets)
      end
    }

    # return result
    render json: {
      links: link_list,
      assets: assets,
    }
  end

  # POST /api/v1/links/add
  def add

    # lookup object id
    object_id = Ticket.where( number: params[:link_object_source_number] ).first.id
    link = Link.add(
      link_type: params[:link_type],
      link_object_target: params[:link_object_target],
      link_object_target_value: params[:link_object_target_value],
      link_object_source: params[:link_object_source],
      link_object_source_value: object_id
    )

    if link
      render json: link, status: :created
    else
      render json: link.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/links/remove
  def remove
    link = Link.remove(params)

    if link
      render json: link, status: :created
    else
      render json: link.errors, status: :unprocessable_entity
    end
  end

end
