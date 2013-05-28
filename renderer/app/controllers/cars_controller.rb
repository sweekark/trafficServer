class CarsController < ApplicationController
  # GET /cars
  # GET /cars.xml
  def index
    @normalizer = Normalizer.all(:from => params[:from],:to=>params[:to])
    @nmalizer = Normalizer.all(
      :"from1.junction.loc" => 
      {
        "$near" => [12.92967, 77.62168]
      },
       :"to1.junction.loc" => 
      {
        "$near" => [12.92967, 77.62168]
      }

    ).first

    Rails.logger.debug("My object: #{params[:points]}")
    Rails.logger.debug("My object: #{@normalizers.inspect}")
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @normalizer  }
    end
  end

  # GET /cars/1
  # GET /cars/1.xml
  def show
    @car = Car.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @car }
    end
  end

  # GET /cars/new
  # GET /cars/new.xml
  def new
    @car = Car.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @car }
    end
  end

  # GET /cars/1/edit
  def edit
    @car = Car.find(params[:id])
  end

  # POST /cars
  # POST /cars.xml
  def create
    @car = Car.new(params[:car])

    respond_to do |format|
      if @car.save
        format.html { redirect_to(@car, :notice => 'Car was successfully created.') }
        format.xml  { render :xml => @car, :status => :created, :location => @car }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @car.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /cars/1
  # PUT /cars/1.xml
  def update
    @car = Car.find(params[:id])

    respond_to do |format|
      if @car.update_attributes(params[:car])
        format.html { redirect_to(@car, :notice => 'Car was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @car.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /cars/1
  # DELETE /cars/1.xml
  def destroy
    @car = Car.find(params[:id])
    @car.destroy

    respond_to do |format|
      format.html { redirect_to(cars_url) }
      format.xml  { head :ok }
    end
  end
end
