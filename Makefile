NAME=libnrthreads
CC=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
AR=ar
DEFS = -DHAVE_CONFIG_H
STD_CFLAGS= -c -I$(shell pwd) -I/usr/local/include -stdlib=libc++ -arch arm64 -fembed-bitcode-marker --sysroot=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS12.2.sdk $(DEFS)
STD_LDFLAGS=
SOURCES=$(shell for file in `find ./$(NAME) \( -name x_*  \) -prune -o -type f -name '*.cpp' -print`;do echo $$file; done)
HEADERS=$(shell for file in `find ./$(NAME) \( -name x_*  \) -prune -o -type f -name '*.h' -print`;do echo $$file; done)
OBJECTS=$(subst $(NAME),build,$(SOURCES:.cpp=.o))
BUILDPATH=./build
INSTALL_HEADER_PATH=/usr/local/include/$(NAME)
INSTALL_LIB_PATH=/usr/local/lib
DST_HEADERS=$(subst ./$(NAME),$(INSTALL_HEADER_PATH),$(HEADERS))
STATIC_LIBRARY=$(NAME).a

all: $(SOURCES) $(STATIC_LIBRARY)
	
$(STATIC_LIBRARY): $(OBJECTS)
	$(AR) rcs $(BUILDPATH)/$@ $(addprefix $(BUILDPATH)/, $(notdir $(OBJECTS)))

$(BUILDPATH)/%.o: copyconfig
	+@[ -d $(BUILDPATH) ] || mkdir -p $(BUILDPATH)
	$(CC) $(STD_CFLAGS) $(CFLAGS) ./$(subst build,$(NAME),$(@:.o=.cpp)) -o $(BUILDPATH)/$(notdir $@)

copyconfig:
	cp config.h ./$(NAME)/config.h

install:$(DST_HEADERS)
	mkdir -p $(INSTALL_HEADER_PATH)
	cp $(BUILDPATH)/$(STATIC_LIBRARY) $(INSTALL_LIB_PATH)/$(STATIC_LIBRARY)

$(DST_HEADERS):
	+@[ -d $(dir $@) ] || mkdir -p $(dir $@)
	cp $(subst $(INSTALL_HEADER_PATH), ./$(NAME), $@) $@

clean:
	rm -Rf $(BUILDPATH)/*.o
	rm -f $(BUILDPATH)/$(STATIC_LIBRARY)

remove:
	rm -Rf $(INSTALL_HEADER_PATH)
	rm -f $(INSTALL_LIB_PATH)/$(STATIC_LIBRARY)

cleanconf:
	rm -Rf config.status
	rm -f config.log
	rm -f Makefile
