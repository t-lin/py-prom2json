MKFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
LIBNAME = pyProm2Json
CPPFLAGS += -I.
LDFLAGS += -L. -l$(LIBNAME)
CXXFLAGS += -std=c++14 -O3 -Wall -pthread -fPIC
LOCAL_PYPATH = /usr/local/lib/python2.7/dist-packages

.PHONY: all clib pylib install

all: lib$(LIBNAME).a $(MKFILE_DIR)build/_$(LIBNAME).so

# Build C archive library from Go
clib: lib$(LIBNAME).a
lib$(LIBNAME).a: prom2json_simple.go
	go build -buildmode=c-archive -o $@ $<

pylib: $(MKFILE_DIR)build/_$(LIBNAME).so
$(MKFILE_DIR)build/_$(LIBNAME).so: CPPFLAGS += -I/usr/include/python2.7
$(MKFILE_DIR)build/_$(LIBNAME).so: pyProm2JsonBytes.cpp lib$(LIBNAME).a
	mkdir -p $(MKFILE_DIR)build
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -DNDEBUG -g -fwrapv -fno-strict-aliasing -Wdate-time -D_FORTIFY_SOURCE=2 -fstack-protector-strong -Wformat -Werror=format-security -c $< -o $(MKFILE_DIR)build/_$(LIBNAME).o
	$(CXX) $(CXXFLAGS) -g -shared -Wl,-O1 -Wl,-Bsymbolic-functions -Wl,-Bsymbolic-functions -Wl,-z,relro -fno-strict-aliasing -DNDEBUG -fwrapv -Wstrict-prototypes -Wdate-time -D_FORTIFY_SOURCE=2 -fstack-protector-strong -Wformat -Werror=format-security $(MKFILE_DIR)build/_$(LIBNAME).o -L$(MKFILE_DIR)build $(LDFLAGS) -o $(MKFILE_DIR)build/_$(LIBNAME).so
	
install: $(MKFILE_DIR)build/_$(LIBNAME).so
	sudo ln -fs $(MKFILE_DIR)build/_$(LIBNAME).so $(LOCAL_PYPATH)/_$(LIBNAME).so

clean:
	rm -rf lib$(LIBNAME).a lib$(LIBNAME).h $(MKFILE_DIR)build
