/**
 * Autogenerated by Thrift Compiler (0.9.0)
 *
 * DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
 *  @generated
 */
#ifndef libs_TYPES_H
#define libs_TYPES_H

#include <thrift/Thrift.h>
#include <thrift/TApplicationException.h>
#include <thrift/protocol/TProtocol.h>
#include <thrift/transport/TTransport.h>



namespace flowbox { namespace batch {

typedef int32_t LibID;

typedef struct _Library__isset {
  _Library__isset() : libID(true), name(false), path(false), rootDefID(true) {}
  bool libID;
  bool name;
  bool path;
  bool rootDefID;
} _Library__isset;

class Library {
 public:

  static const char* ascii_fingerprint; // = "8647601436A6884E958535045FA2944B";
  static const uint8_t binary_fingerprint[16]; // = {0x86,0x47,0x60,0x14,0x36,0xA6,0x88,0x4E,0x95,0x85,0x35,0x04,0x5F,0xA2,0x94,0x4B};

  Library() : libID(-1), name(), path(), rootDefID(-1) {
  }

  virtual ~Library() throw() {}

  LibID libID;
  std::string name;
  std::string path;
  int32_t rootDefID;

  _Library__isset __isset;

  void __set_libID(const LibID val) {
    libID = val;
    __isset.libID = true;
  }

  void __set_name(const std::string& val) {
    name = val;
    __isset.name = true;
  }

  void __set_path(const std::string& val) {
    path = val;
    __isset.path = true;
  }

  void __set_rootDefID(const int32_t val) {
    rootDefID = val;
    __isset.rootDefID = true;
  }

  bool operator == (const Library & rhs) const
  {
    if (__isset.libID != rhs.__isset.libID)
      return false;
    else if (__isset.libID && !(libID == rhs.libID))
      return false;
    if (__isset.name != rhs.__isset.name)
      return false;
    else if (__isset.name && !(name == rhs.name))
      return false;
    if (__isset.path != rhs.__isset.path)
      return false;
    else if (__isset.path && !(path == rhs.path))
      return false;
    if (__isset.rootDefID != rhs.__isset.rootDefID)
      return false;
    else if (__isset.rootDefID && !(rootDefID == rhs.rootDefID))
      return false;
    return true;
  }
  bool operator != (const Library &rhs) const {
    return !(*this == rhs);
  }

  bool operator < (const Library & ) const;

  uint32_t read(::apache::thrift::protocol::TProtocol* iprot);
  uint32_t write(::apache::thrift::protocol::TProtocol* oprot) const;

};

void swap(Library &a, Library &b);

}} // namespace

#endif
