class NormalizersController < ApplicationController
  # POST /normalizer
  # returns the avg time between two location sent in 
  # long lat format
  def index
    @normalizers = Normalizer.get(params)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @normalizers }
    end
  end

  # GET /normalizers/1
  # GET /normalizers/1.json
  def show
    @normalizer = Normalizer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @normalizer }
    end
  end

  # GET /normalizers/new
  # GET /normalizers/new.json
  def new
    @normalizer = Normalizer.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @normalizer }
    end
  end

  # GET /normalizers/1/edit
  def edit
    @normalizer = Normalizer.find(params[:id])
  end

  # POST /normalizers
  # POST /normalizers.json
  def create
    @normalizer = Normalizer.new(params[:normalizer])

    respond_to do |format|
      if @normalizer.save
        format.html { redirect_to @normalizer, notice: 'Normalizer was successfully created.' }
        format.json { render json: @normalizer, status: :created, location: @normalizer }
      else
        format.html { render action: "new" }
        format.json { render json: @normalizer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /normalizers/1
  # PUT /normalizers/1.json
  def update
    @normalizer = Normalizer.find(params[:id])

    respond_to do |format|
      if @normalizer.update_attributes(params[:normalizer])
        format.html { redirect_to @normalizer, notice: 'Normalizer was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @normalizer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /normalizers/1
  # DELETE /normalizers/1.json
  def destroy
    @normalizer = Normalizer.find(params[:id])
    @normalizer.destroy

    respond_to do |format|
      format.html { redirect_to normalizers_url }
      format.json { head :no_content }
    end
  end
end
