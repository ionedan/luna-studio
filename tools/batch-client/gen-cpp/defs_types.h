/**
 * Autogenerated by Thrift Compiler (0.9.0)
 *
 * DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
 *  @generated
 */
#ifndef defs_TYPES_H
#define defs_TYPES_H

#include <thrift/Thrift.h>
#include <thrift/TApplicationException.h>
#include <thrift/protocol/TProtocol.h>
#include <thrift/transport/TTransport.h>

#include "attrs_types.h"
#include "libs_types.h"
#include "types_types.h"


namespace flowbox { namespace batch {

typedef int32_t DefID;

typedef std::vector<class Import>  Imports;

typedef struct _Import__isset {
  _Import__isset() : path(false), items(false) {}
  bool path;
  bool items;
} _Import__isset;

class Import {
 public:

  static const char* ascii_fingerprint; // = "92AA23526EDCB0628C830C8758ED7059";
  static const uint8_t binary_fingerprint[16]; // = {0x92,0xAA,0x23,0x52,0x6E,0xDC,0xB0,0x62,0x8C,0x83,0x0C,0x87,0x58,0xED,0x70,0x59};

  Import() {
  }

  virtual ~Import() throw() {}

  std::vector<std::string>  path;
  std::vector<std::string>  items;

  _Import__isset __isset;

  void __set_path(const std::vector<std::string> & val) {
    path = val;
    __isset.path = true;
  }

  void __set_items(const std::vector<std::string> & val) {
    items = val;
    __isset.items = true;
  }

  bool operator == (const Import & rhs) const
  {
    if (__isset.path != rhs.__isset.path)
      return false;
    else if (__isset.path && !(path == rhs.path))
      return false;
    if (__isset.items != rhs.__isset.items)
      return false;
    else if (__isset.items && !(items == rhs.items))
      return false;
    return true;
  }
  bool operator != (const Import &rhs) const {
    return !(*this == rhs);
  }

  bool operator < (const Import & ) const;

  uint32_t read(::apache::thrift::protocol::TProtocol* iprot);
  uint32_t write(::apache::thrift::protocol::TProtocol* oprot) const;

};

void swap(Import &a, Import &b);

typedef struct _NodeDef__isset {
  _NodeDef__isset() : cls(false), imports(true), flags(true), attribs(true), libID(true), defID(true) {}
  bool cls;
  bool imports;
  bool flags;
  bool attribs;
  bool libID;
  bool defID;
} _NodeDef__isset;

class NodeDef {
 public:

  static const char* ascii_fingerprint; // = "DFA58221D08704BE864C77CAE04E43F5";
  static const uint8_t binary_fingerprint[16]; // = {0xDF,0xA5,0x82,0x21,0xD0,0x87,0x04,0xBE,0x86,0x4C,0x77,0xCA,0xE0,0x4E,0x43,0xF5};

  NodeDef() : libID(-1), defID(-1) {



  }

  virtual ~NodeDef() throw() {}

   ::flowbox::batch::Type cls;
  Imports imports;
   ::flowbox::batch::Flags flags;
   ::flowbox::batch::Attributes attribs;
   ::flowbox::batch::LibID libID;
  DefID defID;

  _NodeDef__isset __isset;

  void __set_cls(const  ::flowbox::batch::Type& val) {
    cls = val;
    __isset.cls = true;
  }

  void __set_imports(const Imports& val) {
    imports = val;
    __isset.imports = true;
  }

  void __set_flags(const  ::flowbox::batch::Flags& val) {
    flags = val;
    __isset.flags = true;
  }

  void __set_attribs(const  ::flowbox::batch::Attributes& val) {
    attribs = val;
    __isset.attribs = true;
  }

  void __set_libID(const  ::flowbox::batch::LibID val) {
    libID = val;
    __isset.libID = true;
  }

  void __set_defID(const DefID val) {
    defID = val;
    __isset.defID = true;
  }

  bool operator == (const NodeDef & rhs) const
  {
    if (__isset.cls != rhs.__isset.cls)
      return false;
    else if (__isset.cls && !(cls == rhs.cls))
      return false;
    if (__isset.imports != rhs.__isset.imports)
      return false;
    else if (__isset.imports && !(imports == rhs.imports))
      return false;
    if (__isset.flags != rhs.__isset.flags)
      return false;
    else if (__isset.flags && !(flags == rhs.flags))
      return false;
    if (__isset.attribs != rhs.__isset.attribs)
      return false;
    else if (__isset.attribs && !(attribs == rhs.attribs))
      return false;
    if (__isset.libID != rhs.__isset.libID)
      return false;
    else if (__isset.libID && !(libID == rhs.libID))
      return false;
    if (__isset.defID != rhs.__isset.defID)
      return false;
    else if (__isset.defID && !(defID == rhs.defID))
      return false;
    return true;
  }
  bool operator != (const NodeDef &rhs) const {
    return !(*this == rhs);
  }

  bool operator < (const NodeDef & ) const;

  uint32_t read(::apache::thrift::protocol::TProtocol* iprot);
  uint32_t write(::apache::thrift::protocol::TProtocol* oprot) const;

};

void swap(NodeDef &a, NodeDef &b);

}} // namespace

#endif
