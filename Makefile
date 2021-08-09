MKFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
LIBNAME = pyProm2Json
CPPFLAGS += -I.
LDFLAGS += -L. -l$(LIBNAME)
CXXFLAGS += -std=c++14 -O3 -Wall -pthread -fPIC

PYVERS=2
#PYHEADERS=
ifeq "$(PYHEADERS)" ""
    ifeq "$(PYVERS)" "3"
        CXXFLAGS += -DPYTHON3
        ifneq "$(wildcard /usr/include/python3.5)" ""
            PYHEADERS = /usr/include/python3.5
            LOCAL_PYPATH = /usr/local/lib/python3.5/dist-packages
        else ifneq "$(wildcard /usr/include/python3.6)" ""
            PYHEADERS = /usr/include/python3.6
            LOCAL_PYPATH = /usr/local/lib/python3.6/dist-packages
        else ifneq "$(wildcard /usr/include/python3.7)" ""
            PYHEADERS = /usr/include/python3.7
            LOCAL_PYPATH = /usr/local/lib/python3.7/dist-packages
        else ifneq "$(wildcard /usr/include/python3.8)" ""
            PYHEADERS = /usr/include/python3.8
            LOCAL_PYPATH = /usr/local/lib/python3.8/dist-packages
        endif
    else
        LOCAL_PYPATH = /usr/local/lib/python2.7/dist-packages
        PYHEADERS = /usr/include/python2.7
    endif
endif

.PHONY: all clib pylib install

all: lib$(LIBNAME).a $(MKFILE_DIR)build/_$(LIBNAME).so

# Build C archive library from Go
clib: lib$(LIBNAME).a
lib$(LIBNAME).a: prom2json_simple.go
	go build -buildmode=c-archive -o $@ $<

pylib: $(MKFILE_DIR)build/_$(LIBNAME).so
$(MKFILE_DIR)build/_$(LIBNAME).so: CPPFLAGS += -I$(PYHEADERS)
$(MKFILE_DIR)build/_$(LIBNAME).so: pyProm2JsonBytes.cpp lib$(LIBNAME).a
ifeq "$(PYHEADERS)" ""
	$(error "Cannot find Python headers; specify the directory via PYHEADERS variable (e.g. make PYHEADERS=<path-to-headers-dir>)")
endif
	mkdir -p $(MKFILE_DIR)build
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -DNDEBUG -g -fwrapv -fno-strict-aliasing -Wdate-time -D_FORTIFY_SOURCE=2 -fstack-protector-strong -Wformat -Werror=format-security -c $< -o $(MKFILE_DIR)build/_$(LIBNAME).o
	$(CXX) $(CXXFLAGS) -g -shared -Wl,-O1 -Wl,-Bsymbolic-functions -Wl,-Bsymbolic-functions -Wl,-z,relro -fno-strict-aliasing -DNDEBUG -fwrapv -Wstrict-prototypes -Wdate-time -D_FORTIFY_SOURCE=2 -fstack-protector-strong -Wformat -Werror=format-security $(MKFILE_DIR)build/_$(LIBNAME).o -L$(MKFILE_DIR)build $(LDFLAGS) -o $(MKFILE_DIR)build/_$(LIBNAME).so
	
install: $(MKFILE_DIR)build/_$(LIBNAME).so
	sudo cp --preserve=timestamps $(MKFILE_DIR)build/_$(LIBNAME).so $(LOCAL_PYPATH)/_$(LIBNAME).so

clean:
	rm -rf lib$(LIBNAME).a lib$(LIBNAME).h $(MKFILE_DIR)build
