// Generated by the protocol buffer compiler.  DO NOT EDIT!

#define INTERNAL_SUPPRESS_PROTOBUF_FIELD_DEPRECATION
#include "library.pb.h"

#include <algorithm>

#include <google/protobuf/stubs/once.h>
#include <google/protobuf/io/coded_stream.h>
#include <google/protobuf/wire_format_lite_inl.h>
#include <google/protobuf/descriptor.h>
#include <google/protobuf/reflection_ops.h>
#include <google/protobuf/wire_format.h>
// @@protoc_insertion_point(includes)

namespace generated {
namespace proto {
namespace library {

namespace {

const ::google::protobuf::Descriptor* Library_descriptor_ = NULL;
const ::google::protobuf::internal::GeneratedMessageReflection*
  Library_reflection_ = NULL;

}  // namespace


void protobuf_AssignDesc_library_2eproto() {
  protobuf_AddDesc_library_2eproto();
  const ::google::protobuf::FileDescriptor* file =
    ::google::protobuf::DescriptorPool::generated_pool()->FindFileByName(
      "library.proto");
  GOOGLE_CHECK(file != NULL);
  Library_descriptor_ = file->message_type(0);
  static const int Library_offsets_[4] = {
    GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(Library, id_),
    GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(Library, name_),
    GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(Library, path_),
    GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(Library, ast_),
  };
  Library_reflection_ =
    new ::google::protobuf::internal::GeneratedMessageReflection(
      Library_descriptor_,
      Library::default_instance_,
      Library_offsets_,
      GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(Library, _has_bits_[0]),
      GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(Library, _unknown_fields_),
      -1,
      ::google::protobuf::DescriptorPool::generated_pool(),
      ::google::protobuf::MessageFactory::generated_factory(),
      sizeof(Library));
}

namespace {

GOOGLE_PROTOBUF_DECLARE_ONCE(protobuf_AssignDescriptors_once_);
inline void protobuf_AssignDescriptorsOnce() {
  ::google::protobuf::GoogleOnceInit(&protobuf_AssignDescriptors_once_,
                 &protobuf_AssignDesc_library_2eproto);
}

void protobuf_RegisterTypes(const ::std::string&) {
  protobuf_AssignDescriptorsOnce();
  ::google::protobuf::MessageFactory::InternalRegisterGeneratedMessage(
    Library_descriptor_, &Library::default_instance());
}

}  // namespace

void protobuf_ShutdownFile_library_2eproto() {
  delete Library::default_instance_;
  delete Library_reflection_;
}

void protobuf_AddDesc_library_2eproto() {
  static bool already_here = false;
  if (already_here) return;
  already_here = true;
  GOOGLE_PROTOBUF_VERIFY_VERSION;

  ::generated::proto::module::protobuf_AddDesc_module_2eproto();
  ::google::protobuf::DescriptorPool::InternalAddGeneratedFile(
    "\n\rlibrary.proto\022\027generated.proto.library"
    "\032\014module.proto\"^\n\007Library\022\n\n\002id\030\001 \001(\005\022\014\n"
    "\004name\030\002 \001(\t\022\014\n\004path\030\003 \001(\t\022+\n\003ast\030\004 \001(\0132\036"
    ".generated.proto.module.Module", 150);
  ::google::protobuf::MessageFactory::InternalRegisterGeneratedFile(
    "library.proto", &protobuf_RegisterTypes);
  Library::default_instance_ = new Library();
  Library::default_instance_->InitAsDefaultInstance();
  ::google::protobuf::internal::OnShutdown(&protobuf_ShutdownFile_library_2eproto);
}

// Force AddDescriptors() to be called at static initialization time.
struct StaticDescriptorInitializer_library_2eproto {
  StaticDescriptorInitializer_library_2eproto() {
    protobuf_AddDesc_library_2eproto();
  }
} static_descriptor_initializer_library_2eproto_;


// ===================================================================

#ifndef _MSC_VER
const int Library::kIdFieldNumber;
const int Library::kNameFieldNumber;
const int Library::kPathFieldNumber;
const int Library::kAstFieldNumber;
#endif  // !_MSC_VER

Library::Library()
  : ::google::protobuf::Message() {
  SharedCtor();
}

void Library::InitAsDefaultInstance() {
  ast_ = const_cast< ::generated::proto::module::Module*>(&::generated::proto::module::Module::default_instance());
}

Library::Library(const Library& from)
  : ::google::protobuf::Message() {
  SharedCtor();
  MergeFrom(from);
}

void Library::SharedCtor() {
  _cached_size_ = 0;
  id_ = 0;
  name_ = const_cast< ::std::string*>(&::google::protobuf::internal::kEmptyString);
  path_ = const_cast< ::std::string*>(&::google::protobuf::internal::kEmptyString);
  ast_ = NULL;
  ::memset(_has_bits_, 0, sizeof(_has_bits_));
}

Library::~Library() {
  SharedDtor();
}

void Library::SharedDtor() {
  if (name_ != &::google::protobuf::internal::kEmptyString) {
    delete name_;
  }
  if (path_ != &::google::protobuf::internal::kEmptyString) {
    delete path_;
  }
  if (this != default_instance_) {
    delete ast_;
  }
}

void Library::SetCachedSize(int size) const {
  GOOGLE_SAFE_CONCURRENT_WRITES_BEGIN();
  _cached_size_ = size;
  GOOGLE_SAFE_CONCURRENT_WRITES_END();
}
const ::google::protobuf::Descriptor* Library::descriptor() {
  protobuf_AssignDescriptorsOnce();
  return Library_descriptor_;
}

const Library& Library::default_instance() {
  if (default_instance_ == NULL) protobuf_AddDesc_library_2eproto();  return *default_instance_;
}

Library* Library::default_instance_ = NULL;

Library* Library::New() const {
  return new Library;
}

void Library::Clear() {
  if (_has_bits_[0 / 32] & (0xffu << (0 % 32))) {
    id_ = 0;
    if (has_name()) {
      if (name_ != &::google::protobuf::internal::kEmptyString) {
        name_->clear();
      }
    }
    if (has_path()) {
      if (path_ != &::google::protobuf::internal::kEmptyString) {
        path_->clear();
      }
    }
    if (has_ast()) {
      if (ast_ != NULL) ast_->::generated::proto::module::Module::Clear();
    }
  }
  ::memset(_has_bits_, 0, sizeof(_has_bits_));
  mutable_unknown_fields()->Clear();
}

bool Library::MergePartialFromCodedStream(
    ::google::protobuf::io::CodedInputStream* input) {
#define DO_(EXPRESSION) if (!(EXPRESSION)) return false
  ::google::protobuf::uint32 tag;
  while ((tag = input->ReadTag()) != 0) {
    switch (::google::protobuf::internal::WireFormatLite::GetTagFieldNumber(tag)) {
      // optional int32 id = 1;
      case 1: {
        if (::google::protobuf::internal::WireFormatLite::GetTagWireType(tag) ==
            ::google::protobuf::internal::WireFormatLite::WIRETYPE_VARINT) {
          DO_((::google::protobuf::internal::WireFormatLite::ReadPrimitive<
                   ::google::protobuf::int32, ::google::protobuf::internal::WireFormatLite::TYPE_INT32>(
                 input, &id_)));
          set_has_id();
        } else {
          goto handle_uninterpreted;
        }
        if (input->ExpectTag(18)) goto parse_name;
        break;
      }
      
      // optional string name = 2;
      case 2: {
        if (::google::protobuf::internal::WireFormatLite::GetTagWireType(tag) ==
            ::google::protobuf::internal::WireFormatLite::WIRETYPE_LENGTH_DELIMITED) {
         parse_name:
          DO_(::google::protobuf::internal::WireFormatLite::ReadString(
                input, this->mutable_name()));
          ::google::protobuf::internal::WireFormat::VerifyUTF8String(
            this->name().data(), this->name().length(),
            ::google::protobuf::internal::WireFormat::PARSE);
        } else {
          goto handle_uninterpreted;
        }
        if (input->ExpectTag(26)) goto parse_path;
        break;
      }
      
      // optional string path = 3;
      case 3: {
        if (::google::protobuf::internal::WireFormatLite::GetTagWireType(tag) ==
            ::google::protobuf::internal::WireFormatLite::WIRETYPE_LENGTH_DELIMITED) {
         parse_path:
          DO_(::google::protobuf::internal::WireFormatLite::ReadString(
                input, this->mutable_path()));
          ::google::protobuf::internal::WireFormat::VerifyUTF8String(
            this->path().data(), this->path().length(),
            ::google::protobuf::internal::WireFormat::PARSE);
        } else {
          goto handle_uninterpreted;
        }
        if (input->ExpectTag(34)) goto parse_ast;
        break;
      }
      
      // optional .generated.proto.module.Module ast = 4;
      case 4: {
        if (::google::protobuf::internal::WireFormatLite::GetTagWireType(tag) ==
            ::google::protobuf::internal::WireFormatLite::WIRETYPE_LENGTH_DELIMITED) {
         parse_ast:
          DO_(::google::protobuf::internal::WireFormatLite::ReadMessageNoVirtual(
               input, mutable_ast()));
        } else {
          goto handle_uninterpreted;
        }
        if (input->ExpectAtEnd()) return true;
        break;
      }
      
      default: {
      handle_uninterpreted:
        if (::google::protobuf::internal::WireFormatLite::GetTagWireType(tag) ==
            ::google::protobuf::internal::WireFormatLite::WIRETYPE_END_GROUP) {
          return true;
        }
        DO_(::google::protobuf::internal::WireFormat::SkipField(
              input, tag, mutable_unknown_fields()));
        break;
      }
    }
  }
  return true;
#undef DO_
}

void Library::SerializeWithCachedSizes(
    ::google::protobuf::io::CodedOutputStream* output) const {
  // optional int32 id = 1;
  if (has_id()) {
    ::google::protobuf::internal::WireFormatLite::WriteInt32(1, this->id(), output);
  }
  
  // optional string name = 2;
  if (has_name()) {
    ::google::protobuf::internal::WireFormat::VerifyUTF8String(
      this->name().data(), this->name().length(),
      ::google::protobuf::internal::WireFormat::SERIALIZE);
    ::google::protobuf::internal::WireFormatLite::WriteString(
      2, this->name(), output);
  }
  
  // optional string path = 3;
  if (has_path()) {
    ::google::protobuf::internal::WireFormat::VerifyUTF8String(
      this->path().data(), this->path().length(),
      ::google::protobuf::internal::WireFormat::SERIALIZE);
    ::google::protobuf::internal::WireFormatLite::WriteString(
      3, this->path(), output);
  }
  
  // optional .generated.proto.module.Module ast = 4;
  if (has_ast()) {
    ::google::protobuf::internal::WireFormatLite::WriteMessageMaybeToArray(
      4, this->ast(), output);
  }
  
  if (!unknown_fields().empty()) {
    ::google::protobuf::internal::WireFormat::SerializeUnknownFields(
        unknown_fields(), output);
  }
}

::google::protobuf::uint8* Library::SerializeWithCachedSizesToArray(
    ::google::protobuf::uint8* target) const {
  // optional int32 id = 1;
  if (has_id()) {
    target = ::google::protobuf::internal::WireFormatLite::WriteInt32ToArray(1, this->id(), target);
  }
  
  // optional string name = 2;
  if (has_name()) {
    ::google::protobuf::internal::WireFormat::VerifyUTF8String(
      this->name().data(), this->name().length(),
      ::google::protobuf::internal::WireFormat::SERIALIZE);
    target =
      ::google::protobuf::internal::WireFormatLite::WriteStringToArray(
        2, this->name(), target);
  }
  
  // optional string path = 3;
  if (has_path()) {
    ::google::protobuf::internal::WireFormat::VerifyUTF8String(
      this->path().data(), this->path().length(),
      ::google::protobuf::internal::WireFormat::SERIALIZE);
    target =
      ::google::protobuf::internal::WireFormatLite::WriteStringToArray(
        3, this->path(), target);
  }
  
  // optional .generated.proto.module.Module ast = 4;
  if (has_ast()) {
    target = ::google::protobuf::internal::WireFormatLite::
      WriteMessageNoVirtualToArray(
        4, this->ast(), target);
  }
  
  if (!unknown_fields().empty()) {
    target = ::google::protobuf::internal::WireFormat::SerializeUnknownFieldsToArray(
        unknown_fields(), target);
  }
  return target;
}

int Library::ByteSize() const {
  int total_size = 0;
  
  if (_has_bits_[0 / 32] & (0xffu << (0 % 32))) {
    // optional int32 id = 1;
    if (has_id()) {
      total_size += 1 +
        ::google::protobuf::internal::WireFormatLite::Int32Size(
          this->id());
    }
    
    // optional string name = 2;
    if (has_name()) {
      total_size += 1 +
        ::google::protobuf::internal::WireFormatLite::StringSize(
          this->name());
    }
    
    // optional string path = 3;
    if (has_path()) {
      total_size += 1 +
        ::google::protobuf::internal::WireFormatLite::StringSize(
          this->path());
    }
    
    // optional .generated.proto.module.Module ast = 4;
    if (has_ast()) {
      total_size += 1 +
        ::google::protobuf::internal::WireFormatLite::MessageSizeNoVirtual(
          this->ast());
    }
    
  }
  if (!unknown_fields().empty()) {
    total_size +=
      ::google::protobuf::internal::WireFormat::ComputeUnknownFieldsSize(
        unknown_fields());
  }
  GOOGLE_SAFE_CONCURRENT_WRITES_BEGIN();
  _cached_size_ = total_size;
  GOOGLE_SAFE_CONCURRENT_WRITES_END();
  return total_size;
}

void Library::MergeFrom(const ::google::protobuf::Message& from) {
  GOOGLE_CHECK_NE(&from, this);
  const Library* source =
    ::google::protobuf::internal::dynamic_cast_if_available<const Library*>(
      &from);
  if (source == NULL) {
    ::google::protobuf::internal::ReflectionOps::Merge(from, this);
  } else {
    MergeFrom(*source);
  }
}

void Library::MergeFrom(const Library& from) {
  GOOGLE_CHECK_NE(&from, this);
  if (from._has_bits_[0 / 32] & (0xffu << (0 % 32))) {
    if (from.has_id()) {
      set_id(from.id());
    }
    if (from.has_name()) {
      set_name(from.name());
    }
    if (from.has_path()) {
      set_path(from.path());
    }
    if (from.has_ast()) {
      mutable_ast()->::generated::proto::module::Module::MergeFrom(from.ast());
    }
  }
  mutable_unknown_fields()->MergeFrom(from.unknown_fields());
}

void Library::CopyFrom(const ::google::protobuf::Message& from) {
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

void Library::CopyFrom(const Library& from) {
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

bool Library::IsInitialized() const {
  
  if (has_ast()) {
    if (!this->ast().IsInitialized()) return false;
  }
  return true;
}

void Library::Swap(Library* other) {
  if (other != this) {
    std::swap(id_, other->id_);
    std::swap(name_, other->name_);
    std::swap(path_, other->path_);
    std::swap(ast_, other->ast_);
    std::swap(_has_bits_[0], other->_has_bits_[0]);
    _unknown_fields_.Swap(&other->_unknown_fields_);
    std::swap(_cached_size_, other->_cached_size_);
  }
}

::google::protobuf::Metadata Library::GetMetadata() const {
  protobuf_AssignDescriptorsOnce();
  ::google::protobuf::Metadata metadata;
  metadata.descriptor = Library_descriptor_;
  metadata.reflection = Library_reflection_;
  return metadata;
}


// @@protoc_insertion_point(namespace_scope)

}  // namespace library
}  // namespace proto
}  // namespace generated

// @@protoc_insertion_point(global_scope)
