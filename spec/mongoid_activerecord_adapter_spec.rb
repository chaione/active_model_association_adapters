require 'spec_helper'

describe ActiveModelAssociationAdapters do
  
  ActiveRecord::Base.send(:include, ActiveRecord::Adapters::Mongoid::Associations)
  
  describe "ActiveRecord to Mongoid adapters" do
    describe "has_one_document" do
      context "simple cases" do
        class Monkey < ActiveRecord::Base
          has_one_document :banana
        end

        class Banana
          include Mongoid::Document
          field :monkey_id, :type => Integer
        end

        subject {Monkey.new}

        it "should have :banana in its @__has_one_documents" do
          subject.class.instance_variable_get(:@__has_one_documents).should eql([:banana])
        end

        it "should respond_to :banana" do
          subject.should respond_to(:banana)
        end

        it "should respond_to :banana=" do
          subject.should respond_to(:banana=)
        end

        its(:banana) {should be_nil}

        describe "adding a banana" do
          let(:banana_1) {Banana.new}
          let(:banana_2) {Banana.new}

          context "when unsaved" do
            context "without an existing banana" do
              it "should get a banana" do
                subject.banana = banana_1
                subject.banana.should eql banana_1
              end
            end

            context "with an existing banana" do
              before(:each) do
                subject.banana = banana_1
              end

              it "swaps out the banana" do
                subject.banana = banana_2
                subject.banana.should eql banana_2
              end
            end
          end

          context "when saved" do
            subject {Monkey.create}
            context "without an existing banana" do
              it "should get a banana" do
                subject.banana = banana_1
                subject.banana.should eql banana_1
              end
            end

            context "with an existing banana" do
              before(:each) do
                subject.banana = banana_1
              end
              it "swaps out the banana" do
                subject.banana = banana_2
                subject.banana.should eql banana_2
              end

              it "modifies the new banana's monkey_id" do
                subject.banana.monkey_id.should eql(subject.id)
              end
            end

            describe "saving" do
              context "when the banana is a new record" do
                it "saves the banana" do
                  subject.banana = banana_1              
                  subject.save
                  Banana.find(banana_1.id).monkey_id.should eql(subject.id)
                end
              end

              context "when the banana is already saved" do
                before(:each) do
                  banana_1.save
                end

                it "saves the banana's new foreign key" do
                  subject.banana = banana_1
                  subject.save
                  Banana.find(banana_1.id).monkey_id.should eql(subject.id)
                end
              end

              context "when switching bananas" do
                context "when the first banana is saved and the second is a new record" do
                  before(:each) do
                    banana_1.save
                    subject.banana = banana_1
                    subject.save
                    subject.banana = banana_2
                    subject.save
                  end

                  it "unsets the monkey_id for the first banana" do
                    Banana.find(banana_1.id).monkey_id.should be_nil
                  end              
                end
              end
            end
          end
        end

        describe "builder methods" do
          its(:build_banana) {should be_an_instance_of(Banana)}
          describe "create_banana" do
            it "should be an instance of Banana" do
              banana = subject.create_banana
              banana.should be_an_instance_of(Banana)
              banana.should_not be_new_record
            end        
          end
        end
      end
      
      context "options" do
        class FileThingie < ActiveRecord::Base
          has_one_document :metadata, :class_name => "Metadata"
          has_many_documents :reads, :class_name => "Access"
        end
        
        class Metadata
          include Mongoid::Document
        end
        
        class Access
          include Mongoid::Document
        end
        
        describe "class_name option" do
          subject {FileThingie.create}
          before(:each) do
            Metadata.should_receive(:find).any_number_of_times
            Access.should_receive(:find).any_number_of_times
          end
          
          it "defines has_one accessors with the provided class name" do
            lambda {subject.metadata}.should_not raise_error(NameError)
          end
          
          it "defines has_one accessors with the provided class name" do
            lambda {subject.reads}.should_not raise_error(NameError)
          end
        end
      end
      
    end

    describe "has_many_documents" do
      class Monkey < ActiveRecord::Base
        include ActiveRecord::Adapters::Mongoid::Associations
        has_many_documents :bananas
      end

      class Banana
        include Mongoid::Document
        field :monkey_id, :type => Integer
      end

      subject {Monkey.new}

      it "should have :bananas in its @__has_many_documents" do
        subject.class.instance_variable_get(:@__has_many_documents).should eql([:bananas])
      end

      it "should respond_to :bananas" do
        subject.should respond_to(:bananas)
      end

      it "should respond_to :banana=" do
        subject.should respond_to(:bananas=)
      end

      its(:bananas) {should be_an_instance_of(Mongoid::Criteria)}

      describe "adding a banana" do
        let(:banana_1) {Banana.new}
        let(:banana_2) {Banana.new}
        let(:banana_3) {Banana.new}

        context "when unsaved" do
          context "without existing bananas" do
            it "should get a banana array" do
              subject.bananas = [banana_1]
              subject.bananas.should eql [banana_1]
            end
          end

          context "with existing bananas" do
            before(:each) do
              subject.bananas = [banana_1]
            end

            it "swaps out the bananas arrays" do
              subject.bananas = [banana_2]
              subject.bananas.should eql [banana_2]
            end
          end
        end

        context "when saved" do
          subject {Monkey.create}
          context "without existing bananas" do
            it "should get a banana array" do
              subject.bananas = [banana_1]
              subject.bananas.should eql [banana_1]
            end
          end

          context "with existing bananas" do
            before(:each) do
              subject.bananas = [banana_1]
            end
            it "swaps out the bananas arrays" do
              subject.bananas = [banana_2]
              subject.bananas.should eql [banana_2]
            end

            it "modifies the new bananas' monkey_ids" do
              subject.bananas.each do |banana|
                banana.monkey_id.should eql(subject.id)
              end
            end
          end

          describe "saving" do
            context "when one of the bananas is a new record" do
              it "saves the banana" do
                subject.bananas = [banana_1]              
                subject.save
                Banana.find(banana_1.id).monkey_id.should eql(subject.id)
              end
            end

            context "when one of the bananas is already saved" do
              before(:each) do
                banana_1.save
              end

              it "saves the banana's new foreign key" do
                subject.bananas = [banana_1]
                subject.save
                Banana.find(banana_1.id).monkey_id.should eql(subject.id)
              end
            end

            context "when switching bananas" do
              context "when the first banana is saved and the second is a new record" do
                before(:each) do
                  [banana_1, banana_2].each {|banana| banana.save}
                  subject.bananas = [banana_1, banana_2]
                  subject.save
                  subject.bananas = [banana_2, banana_3]
                  subject.save
                end

                it "unsets the monkey_id for banana_1" do
                  Banana.find(banana_1.id).monkey_id.should be_nil
                end              
              end
            end
          end
        end
      end

      describe "builder methods" do
        its(:build_banana) {should be_an_instance_of(Banana)}
        describe "create_banana" do
          it "should be an instance of Banana" do
            banana = subject.create_banana
            banana.should be_an_instance_of(Banana)
            banana.should_not be_new_record
          end        
        end
      end 
    end    
  end
  
end