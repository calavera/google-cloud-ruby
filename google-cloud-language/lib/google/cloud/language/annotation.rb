# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "google/cloud/core/grpc_utils"

module Google
  module Cloud
    module Language
      ##
      # # Annotation
      #
      # The results of all requested document analysis features.
      #
      # See {Project#annotate} and {Document#annotate}.
      #
      # @example
      #   require "google/cloud/language"
      #
      #   language = Google::Cloud::Language.new
      #
      #   content = "Star Wars is a great movie. The Death Star is fearsome."
      #   document = language.document content
      #   annotation = document.annotate
      #
      #   annotation.sentiment.score #=> 0.10000000149011612
      #   annotation.sentiment.magnitude #=> 1.100000023841858
      #   annotation.entities.count #=> 3
      #   annotation.sentences.count #=> 2
      #   annotation.tokens.count #=> 13
      #
      class Annotation
        ##
        # @private The AnnotateTextResponse Google API Client object.
        attr_accessor :grpc

        ##
        # @private Creates a new Annotation instance.
        def initialize
          @grpc = nil
        end

        ##
        # The sentences returned by syntactic analysis.
        #
        # @return [Array<TextSpan>] an array of pieces of text including
        #   relative location
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Star Wars is a great movie. The Death Star is fearsome."
        #   document = language.document content
        #   annotation = document.annotate
        #
        #   sentence = annotation.sentences.last
        #   sentence.text #=> "The Death Star is fearsome."
        #   sentence.offset #=> 28
        #
        def sentences
          @sentences ||= Array(grpc.sentences).map { |g| Sentence.from_grpc g }
        end

        ##
        # The tokens returned by syntactic analysis.
        #
        # @return [Array<Token>] an array of the smallest syntactic building
        #   blocks of the text
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Star Wars is a great movie. The Death Star is fearsome."
        #   document = language.document content
        #   annotation = document.annotate
        #
        #   annotation.tokens.count #=> 13
        #   token = annotation.tokens.first
        #
        #   token.text #=> "Star"
        #   token.offset #=> 0
        #   token.part_of_speech.tag #=> :NOUN
        #   token.head_token_index #=> 1
        #   token.label #=> :TITLE
        #   token.lemma #=> "Star"
        #
        def tokens
          @tokens ||= Array(grpc.tokens).map { |g| Token.from_grpc g }
        end

        ##
        # The result of syntax analysis.
        #
        # @return [Syntax]
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Star Wars is a great movie. The Death Star is fearsome."
        #   document = language.document content
        #   annotation = document.annotate
        #   syntax = annotation.syntax
        #
        #   sentence = syntax.sentences.last
        #   sentence.text #=> "The Death Star is fearsome."
        #   sentence.offset #=> 28
        #
        #   syntax.tokens.count #=> 13
        #   token = syntax.tokens.first
        #
        #   token.text #=> "Star"
        #   token.offset #=> 0
        #   token.part_of_speech.tag #=> :NOUN
        #   token.head_token_index #=> 1
        #   token.label #=> :TITLE
        #   token.lemma #=> "Star"
        #
        def syntax
          return nil if @grpc.tokens.nil?
          @syntax ||= Syntax.from_grpc @grpc
        end

        ##
        # The entities returned by entity analysis.
        #
        # @return [Entities]
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Star Wars is a great movie. The Death Star is fearsome."
        #   document = language.document content
        #   annotation = document.annotate
        #
        #   entities = annotation.entities
        #   entities.count #=> 3
        #   entity = entities.first
        #
        #   entity.name #=> "Star Wars"
        #   entity.type #=> :WORK_OF_ART
        #   entity.salience #=> 0.6457656025886536
        #   entity.mentions.count #=> 1
        #   entity.mentions.first.text # => "Star Wars"
        #   entity.mentions.first.offset # => 0
        #   entity.mid #=> "/m/06mmr"
        #   entity.wikipedia_url #=> "http://en.wikipedia.org/wiki/Star_Wars"
        #
        def entities
          @entities ||= Entities.from_grpc @grpc
        end

        ##
        # The result of sentiment analysis.
        #
        # @return [Sentiment]
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Star Wars is a great movie. The Death Star is fearsome."
        #   document = language.document content
        #   annotation = document.annotate
        #   sentiment = annotation.sentiment
        #
        #   sentiment.score #=> 0.10000000149011612
        #   sentiment.magnitude #=> 1.100000023841858
        #   sentiment.language #=> "en"
        #
        #   sentence = sentiment.sentences.first
        #   sentence.sentiment.score #=> 0.699999988079071
        #   sentence.sentiment.magnitude #=> 0.699999988079071
        #
        def sentiment
          return nil if @grpc.document_sentiment.nil?
          @sentiment ||= Sentiment.from_grpc @grpc
        end

        ##
        # The language of the document (if not specified, the language is
        # automatically detected). Both ISO and BCP-47 language codes are
        # supported.
        #
        # @return [String] the language code
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Star Wars is a great movie. The Death Star is fearsome."
        #   document = language.document content
        #   annotation = document.annotate
        #   annotation.language #=> "en"
        #
        def language
          @grpc.language
        end

        # @private
        def to_s
          tmplt = "(sentences: %i, tokens: %i, entities: %i," \
                  " sentiment: %s, language: %s)"
          format tmplt, sentences.count, tokens.count, entities.count,
                 !sentiment.nil?, language.inspect
        end

        # @private
        def inspect
          "#<#{self.class.name} #{self}>"
        end

        ##
        # @private New Annotation from a V1::AnnotateTextResponse object.
        def self.from_grpc grpc
          new.tap { |a| a.instance_variable_set :@grpc, grpc }
        end

        ##
        # Represents a piece of text including relative location.
        #
        # @attr_reader [String] text The content of the output text.
        # @attr_reader [Integer] offset The API calculates the beginning offset
        #   of the content in the original document according to the `encoding`
        #   specified in the API request.
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Star Wars is a great movie. The Death Star is fearsome."
        #   document = language.document content
        #   annotation = document.annotate
        #
        #   sentence = annotation.sentences.last
        #   text_span = sentence.text_span
        #   sentence.text #=> "The Death Star is fearsome."
        #   sentence.offset #=> 28
        #
        class TextSpan
          attr_reader :text, :offset
          alias_method :content, :text
          alias_method :begin_offset, :offset

          ##
          # @private Creates a new Token instance.
          def initialize text, offset
            @text   = text
            @offset = offset
          end

          ##
          # @private New TextSpan from a V1::TextSpan object.
          def self.from_grpc grpc
            new grpc.content, grpc.begin_offset
          end
        end

        ##
        # Provides grammatical information, including morphological information,
        # about a token, such as the token's tense, person, number, gender,
        # and so on. Only some of these attributes will be applicable to any
        # given part of speech. Parts of speech are as defined in [A Universal
        # Part-of-Speech Tagset]http://www.lrec-conf.org/proceedings/lrec2012/pdf/274_Paper.pdf
        #
        # @attr_reader [Symbol] tag The part of speech tag.
        # @attr_reader [Symbol] aspect The grammatical aspect.
        # @attr_reader [Symbol] case The grammatical case.
        # @attr_reader [Symbol] form The grammatical form.
        # @attr_reader [Symbol] gender The grammatical gender.
        # @attr_reader [Symbol] mood The grammatical mood.
        # @attr_reader [Symbol] number The grammatical number.
        # @attr_reader [Symbol] person The grammatical person.
        # @attr_reader [Symbol] proper The grammatical properness.
        # @attr_reader [Symbol] reciprocity The grammatical reciprocity.
        # @attr_reader [Symbol] tense The grammatical tense.
        # @attr_reader [Symbol] voice The grammatical voice.
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Star Wars is a great movie. The Death Star is fearsome."
        #   document = language.document content
        #   annotation = document.annotate
        #
        #   annotation.tokens.count #=> 13
        #   token = annotation.tokens.first
        #
        #   token.text_span.text #=> "Star"
        #   token.part_of_speech.tag #=> :NOUN
        #   token.part_of_speech.number #=> :SINGULAR
        #
        class PartOfSpeech
          attr_reader :tag, :aspect, :case, :form, :gender, :mood, :number,
                      :person, :proper, :reciprocity, :tense, :voice

          ##
          # @private Creates a new PartOfSpeech instance.
          def initialize tag, aspect, kase, form, gender, mood, number, person,
                         proper, reciprocity, tense, voice
            @tag = tag
            @aspect = aspect
            @case = kase
            @form = form
            @gender = gender
            @mood = mood
            @number = number
            @person = person
            @proper = proper
            @reciprocity = reciprocity
            @tense = tense
            @voice = voice
          end

          ##
          # @private New TextSpan from a V1::PartOfSpeech object.
          def self.from_grpc grpc
            new grpc.tag, grpc.aspect, grpc.case, grpc.form, grpc.gender,
                grpc.mood, grpc.number, grpc.person, grpc.proper,
                grpc.reciprocity, grpc.tense, grpc.voice
          end
        end

        # Represents a piece of text including relative location.
        #
        # @attr_reader [TextSpan] text_span The sentence text.
        # @attr_reader [Sentence::Sentiment] sentiment The sentence sentiment.
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Star Wars is a great movie. The Death Star is fearsome."
        #   document = language.document content
        #   annotation = document.annotate
        #
        #   annotation.sentences.count #=> 2
        #   sentence = annotation.sentences.first
        #   sentence.text #=> "Star Wars is a great movie."
        #   sentence.offset #=> 0
        #
        class Sentence
          attr_reader :text_span, :sentiment

          ##
          # @private Creates a new Sentence instance.
          def initialize text_span, sentiment
            @text_span = text_span
            @sentiment = sentiment
          end

          ##
          # The content of the output text. See {TextSpan#text}.
          #
          # @return [String]
          #
          def text
            text_span.text
          end
          alias_method :content, :text

          ##
          # The API calculates the beginning offset of the content in the
          # original document according to the `encoding` specified in the
          # API request. See {TextSpan#offset}.
          #
          # @return [Integer]
          #
          def offset
            text_span.offset
          end
          alias_method :begin_offset, :offset

          # Returns `true` if the Sentence has a Sentiment.
          #
          # @return [Boolean]
          #
          def sentiment?
            !sentiment.nil?
          end

          ##
          # Score. See {Sentence::Sentiment#score}.
          #
          # @return [Float]
          #
          def score
            return nil unless sentiment?
            sentiment.score
          end

          ##
          # A non-negative number in the [0, +inf] range, which represents the
          # absolute magnitude of sentiment regardless of score (positive or
          # negative). See {Sentence::Sentiment#magnitude}.
          #
          # @return [Float]
          #
          def magnitude
            return nil unless sentiment?
            sentiment.magnitude
          end

          ##
          # @private New Sentence from a V1::Sentence object.
          def self.from_grpc grpc
            text_span = TextSpan.from_grpc grpc.text
            sentiment = Sentence::Sentiment.from_grpc grpc.sentiment
            new text_span, sentiment
          end

          ##
          # Represents the result of sentiment analysis.
          #
          # @attr_reader [Float] score The overall emotional leaning of the text
          #   in the [-1.0, 1.0] range. Larger numbers represent more positive
          #   sentiments.
          # @attr_reader [Float] magnitude A non-negative number in the
          #   [0, +inf] range, which represents the overall strength of emotion
          #   regardless of score (positive or negative). Unlike score,
          #   magnitude is not normalized; each expression of emotion within the
          #   text (both positive and negative) contributes to the text's
          #   magnitude (so longer text blocks may have greater magnitudes).
          #
          # @example
          #   require "google/cloud/language"
          #
          #   language = Google::Cloud::Language.new
          #
          #   content = "Star Wars is a great movie. \
          #              The Death Star is fearsome."
          #   document = language.document content
          #   annotation = document.annotate
          #   sentiment = annotation.sentiment
          #
          #   sentiment.score #=> 0.10000000149011612
          #   sentiment.magnitude #=> 1.100000023841858
          #   sentiment.language #=> "en"
          #
          #   sentence = sentiment.sentences.first
          #   sentence.sentiment.score #=> 0.699999988079071
          #   sentence.sentiment.magnitude #=> 0.699999988079071
          #
          class Sentiment
            attr_reader :score, :magnitude

            ##
            # @private Creates a new Sentence::Sentiment instance.
            def initialize score, magnitude
              @score     = score
              @magnitude = magnitude
            end

            ##
            # @private New Sentence::Sentiment from a V1::Sentiment object.
            def self.from_grpc grpc
              return nil if grpc.nil?
              new grpc.score, grpc.magnitude
            end
          end
        end

        ##
        # Represents the smallest syntactic building block of the text. Returned
        # by syntactic analysis.
        #
        # @attr_reader [TextSpan] text_span The token text.
        # @attr_reader [PartOfSpeech] part_of_speech Represents part of speech
        #   information for a token.
        # @attr_reader [Integer] head_token_index Represents the head of this
        #   token in the dependency tree. This is the index of the token which
        #   has an arc going to this token. The index is the position of the
        #   token in the array of tokens returned by the API method. If this
        #   token is a root token, then the headTokenIndex is its own index.
        # @attr_reader [Symbol] label The parse label for the token.
        # @attr_reader [String] lemma [Lemma](https://en.wikipedia.org/wiki/Lemma_(morphology))
        #   of the token.
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Star Wars is a great movie. The Death Star is fearsome."
        #   document = language.document content
        #   annotation = document.annotate
        #
        #   annotation.tokens.count #=> 13
        #   token = annotation.tokens.first
        #
        #   token.text_span.text #=> "Star"
        #   token.text_span.offset #=> 0
        #   token.part_of_speech.tag #=> :NOUN
        #   token.part_of_speech.number #=> :SINGULAR
        #   token.head_token_index #=> 1
        #   token.label #=> :TITLE
        #   token.lemma #=> "Star"
        #
        class Token
          attr_reader :text_span, :part_of_speech, :head_token_index, :label,
                      :lemma

          ##
          # @private Creates a new Token instance.
          def initialize text_span, part_of_speech, head_token_index, label,
                         lemma
            @text_span        = text_span
            @part_of_speech   = part_of_speech
            @head_token_index = head_token_index
            @label            = label
            @lemma            = lemma
          end

          def text
            @text_span.text
          end
          alias_method :content, :text

          def offset
            @text_span.offset
          end
          alias_method :begin_offset, :offset

          ##
          # @private New Token from a V1::Token object.
          def self.from_grpc grpc
            text_span = TextSpan.from_grpc grpc.text
            part_of_speech = PartOfSpeech.from_grpc grpc.part_of_speech
            new text_span, part_of_speech,
                grpc.dependency_edge.head_token_index,
                grpc.dependency_edge.label, grpc.lemma
          end
        end

        ##
        # Represents the result of syntax analysis.
        #
        # @attr_reader [Array<Sentence>] sentences The sentences returned by
        #   syntax analysis.
        # @attr_reader [Array<Token>] sentences The tokens returned by
        #   syntax analysis.
        # @attr_reader [String] language The language of the document (if not
        #   specified, the language is automatically detected). Both ISO and
        #   BCP-47 language codes are supported.
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Star Wars is a great movie. The Death Star is fearsome."
        #   document = language.document content
        #   annotation = document.annotate
        #
        #   syntax = annotation.syntax
        #
        #   sentence = syntax.sentences.last
        #   sentence.text #=> "The Death Star is fearsome."
        #   sentence.offset #=> 28
        #
        #   syntax.tokens.count #=> 13
        #   token = syntax.tokens.first
        #
        #   token.text_span.text #=> "Star"
        #   token.text_span.offset #=> 0
        #   token.part_of_speech.tag #=> :NOUN
        #   token.part_of_speech.number #=> :SINGULAR
        #   token.head_token_index #=> 1
        #   token.label #=> :TITLE
        #   token.lemma #=> "Star"
        #
        class Syntax
          attr_reader :sentences, :tokens, :language

          ##
          # @private Creates a new Syntax instance.
          def initialize sentences, tokens, language
            @sentences = sentences
            @tokens    = tokens
            @language  = language
          end

          ##
          # @private New Syntax from a V1::AnnotateTextResponse or
          # V1::AnalyzeSyntaxResponse object.
          def self.from_grpc grpc
            new Array(grpc.sentences).map { |g| Sentence.from_grpc g },
                Array(grpc.tokens).map { |g| Token.from_grpc g },
                grpc.language
          end
        end

        ##
        # The entities returned by entity analysis.
        #
        # @attr_reader [String] language The language of the document (if not
        #   specified, the language is automatically detected). Both ISO and
        #   BCP-47 language codes are supported.
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Star Wars is a great movie. The Death Star is fearsome."
        #   document = language.document content
        #   annotation = document.annotate
        #
        #   entities = annotation.entities
        #   entities.count #=> 3
        #   entities.people.count #=> 1
        #   entities.artwork.count #=> 1
        #
        class Entities < DelegateClass(::Array)
          attr_accessor :language

          ##
          # @private Create a new Entities with an array of Entity instances.
          def initialize entities = [], language = nil
            super entities
            @language = language
          end

          ##
          # Returns the entities for which {Entity#type} is `:UNKNOWN`.
          #
          # @return [Array<Entity>]
          #
          def unknown
            select(&:unknown?)
          end

          ##
          # Returns the entities for which {Entity#type} is `:PERSON`.
          #
          # @return [Array<Entity>]
          #
          def people
            select(&:person?)
          end

          ##
          # Returns the entities for which {Entity#type} is `:LOCATION`.
          #
          # @return [Array<Entity>]
          #
          def locations
            select(&:location?)
          end
          alias_method :places, :locations

          ##
          # Returns the entities for which {Entity#type} is `:ORGANIZATION`.
          #
          # @return [Array<Entity>]
          #
          def organizations
            select(&:organization?)
          end

          ##
          # Returns the entities for which {Entity#type} is `:EVENT`.
          #
          # @return [Array<Entity>]
          #
          def events
            select(&:event?)
          end

          ##
          # Returns the entities for which {Entity#type} is `:WORK_OF_ART`.
          #
          # @return [Array<Entity>]
          #
          def artwork
            select(&:artwork?)
          end

          ##
          # Returns the entities for which {Entity#type} is `:CONSUMER_GOOD`.
          #
          # @return [Array<Entity>]
          #
          def goods
            select(&:good?)
          end

          ##
          # Returns the entities for which {Entity#type} is `:OTHER`.
          #
          # @return [Array<Entity>]
          #
          def other
            select(&:other?)
          end

          ##
          # @private New Entities from a V1::AnnotateTextResponse or
          # V1::AnalyzeEntitiesResponse object.
          def self.from_grpc grpc
            entities = Array(grpc.entities).map { |g| Entity.from_grpc g }
            new entities, grpc.language
          end
        end

        ##
        # Represents a phrase in the text that is a known entity, such as a
        # person, an organization, or location. The API associates information,
        # such as salience and mentions, with entities.
        #
        # @attr_reader [String] name The representative name for the entity.
        # @attr_reader [Symbol] type The type of the entity.
        # @attr_reader [Hash<String,String>] metadata Metadata associated with
        #   the entity. Currently, only Wikipedia URLs are provided, if
        #   available. The associated key is "wikipedia_url".
        # @attr_reader [Float] salience The salience score associated with the
        #   entity in the [0, 1.0] range. The salience score for an entity
        #   provides information about the importance or centrality of that
        #   entity to the entire document text. Scores closer to 0 are less
        #   salient, while scores closer to 1.0 are highly salient.
        # @attr_reader [Array<Entity::Mention>] mentions The mentions of this
        #   entity in the input document. The API currently supports proper noun
        #   mentions.
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Star Wars is a great movie. The Death Star is fearsome."
        #   document = language.document content
        #   annotation = document.annotate
        #
        #   entities = annotation.entities
        #   entities.count #=> 3
        #   entity = entities.first
        #
        #   entity.name #=> "Star Wars"
        #   entity.type #=> :WORK_OF_ART
        #   entity.salience #=> 0.6457656025886536
        #   entity.mentions.count #=> 1
        #   entity.mentions.first.text # => "Star Wars"
        #   entity.mentions.first.offset # => 0
        #   entity.mid #=> "/m/06mmr"
        #   entity.wikipedia_url #=> "http://en.wikipedia.org/wiki/Star_Wars"
        #
        class Entity
          attr_reader :name, :type, :metadata, :salience, :mentions

          ##
          # @private Creates a new Entity instance.
          def initialize name, type, metadata, salience, mentions
            @name     = name
            @type     = type
            @metadata = metadata
            @salience = salience
            @mentions = mentions
          end

          ##
          # Returns `true` if {#type} is `:UNKNOWN`.
          #
          # @return [Boolean]
          #
          def unknown?
            type == :UNKNOWN
          end

          ##
          # Returns `true` if {#type} is `:PERSON`.
          #
          # @return [Boolean]
          #
          def person?
            type == :PERSON
          end

          ##
          # Returns `true` if {#type} is `:LOCATION`.
          #
          # @return [Boolean]
          #
          def location?
            type == :LOCATION
          end
          alias_method :place?, :location?

          ##
          # Returns `true` if {#type} is `:ORGANIZATION`.
          #
          # @return [Boolean]
          #
          def organization?
            type == :ORGANIZATION
          end

          ##
          # Returns `true` if {#type} is `:EVENT`.
          #
          # @return [Boolean]
          #
          def event?
            type == :EVENT
          end

          ##
          # Returns `true` if {#type} is `:WORK_OF_ART`.
          #
          # @return [Boolean]
          #
          def artwork?
            type == :WORK_OF_ART
          end

          ##
          # Returns `true` if {#type} is `:CONSUMER_GOOD`.
          #
          # @return [Boolean]
          #
          def good?
            type == :CONSUMER_GOOD
          end

          ##
          # Returns `true` if {#type} is `:OTHER`.
          #
          # @return [Boolean]
          #
          def other?
            type == :OTHER
          end

          ##
          # Returns the `wikipedia_url` property of the {#metadata}.
          #
          # @return [String]
          #
          def wikipedia_url
            metadata["wikipedia_url"]
          end

          ##
          # Returns the `mid` property of the {#metadata}. The MID
          # (machine-generated identifier) (MID) correspods to the entity's
          # [Google Knowledge Graph](https://www.google.com/intl/bn/insidesearch/features/search/knowledge.html)
          # entry. Note that MID values remain unique across different
          # languages, so you can use such values to tie entities together from
          # different languages. For programmatically inspecting these MID
          # values, please consult the [Google Knowledge Graph Search
          # API](https://developers.google.com/knowledge-graph/) documentation.
          #
          # @return [String]
          #
          def mid
            metadata["mid"]
          end

          ##
          # @private New Entity from a V1::Entity object.
          def self.from_grpc grpc
            metadata = Core::GRPCUtils.map_to_hash grpc.metadata
            mentions = Array(grpc.mentions).map do |g|
              text_span = TextSpan.from_grpc g.text
              Mention.new text_span, g.type
            end
            new grpc.name, grpc.type, metadata, grpc.salience, mentions
          end

          ##
          # Represents a piece of text including relative location.
          #
          # @attr_reader [TextSpan] text_span The entity mention text.
          # @attr_reader [Symbol] type The type of the entity mention. The
          #   possible return values are `:TYPE_UNKNOWN`, `:PROPER` (proper
          #   name), and `:COMMON` (Common noun or noun compound).
          #
          #
          # @example
          #   require "google/cloud/language"
          #
          #   language = Google::Cloud::Language.new
          #
          #   content = "Star Wars is a great movie. \
          #              The Death Star is fearsome."
          #   document = language.document content
          #   annotation = document.annotate
          #
          #   entities = annotation.entities
          #   entities.count #=> 3
          #   entity = entities.first
          #
          #   entity.mentions.count #=> 1
          #   mention = entity.mentions.first
          #   mention.text # => "Star Wars"
          #   mention.offset # => 0
          #   mention.proper? # => true
          #   mention.type # => :PROPER
          #
          class Mention
            attr_reader :text_span, :type

            ##
            # @private Creates a new Entity::Mention instance.
            def initialize text_span, type
              @text_span = text_span
              @type      = type
            end

            ##
            # The content of the output text. See {TextSpan#text}.
            #
            # @return [String]
            #
            def text
              text_span.text
            end
            alias_method :content, :text

            ##
            # The API calculates the beginning offset of the content in the
            # original document according to the `encoding` specified in the
            # API request. See {TextSpan#offset}.
            #
            # @return [Integer]
            #
            # @attr_reader [Integer] offset
            def offset
              text_span.offset
            end
            alias_method :begin_offset, :offset

            ##
            # Returns `true` if {#type} is `:PROPER`.
            #
            # @return [Boolean]
            #
            def proper?
              type == :PROPER
            end

            ##
            # Returns `true` if {#type} is `:COMMON`.
            #
            # @return [Boolean]
            #
            def common?
              type == :COMMON
            end

            ##
            # @private New TextSpan from a V1::TextSpan object.
            def self.from_grpc grpc
              new grpc.content, grpc.begin_offset
            end
          end
        end

        ##
        # Represents the result of sentiment analysis.
        #
        # @attr_reader [Float] score The overall emotional leaning of the text
        #   in the [-1.0, 1.0] range. Larger numbers represent more positive
        #   sentiments.
        # @attr_reader [Float] magnitude A non-negative number in the [0, +inf]
        #   range, which represents the overall strength of emotion
        #   regardless of score (positive or negative). Unlike score, magnitude
        #   is not normalized; each expression of emotion within the text (both
        #   positive and negative) contributes to the text's magnitude (so
        #   longer text blocks may have greater magnitudes).
        # @attr_reader [Array<Sentence>] sentences The sentences returned by
        #   sentiment analysis.
        # @attr_reader [String] language The language of the document (if not
        #   specified, the language is automatically detected). Both ISO and
        #   BCP-47 language codes are supported.
        #
        # @example
        #   require "google/cloud/language"
        #
        #   language = Google::Cloud::Language.new
        #
        #   content = "Star Wars is a great movie. The Death Star is fearsome."
        #   document = language.document content
        #   annotation = document.annotate
        #
        #   sentiment = annotation.sentiment
        #   sentiment.score #=> 0.10000000149011612
        #   sentiment.magnitude #=> 1.100000023841858
        #   sentiment.language #=> "en"
        #
        class Sentiment
          attr_reader :score, :magnitude, :sentences, :language

          ##
          # @private Creates a new Sentiment instance.
          def initialize score, magnitude, sentences, language
            @score     = score
            @magnitude = magnitude
            @sentences = sentences
            @language  = language
          end

          ##
          # @private New Sentiment from a V1::AnnotateTextResponse or
          # V1::AnalyzeSentimentResponse object.
          def self.from_grpc grpc
            new grpc.document_sentiment.score,
                grpc.document_sentiment.magnitude,
                Array(grpc.sentences).map { |g| Sentence.from_grpc g },
                grpc.language
          end
        end
      end
    end
  end
end
