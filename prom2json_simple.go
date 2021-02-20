// Copyright 2014 Prometheus Team
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import "C"

import (
	"bytes"
	"encoding/json"
	"io"
	//"time"
	"log"

	dto "github.com/prometheus/client_model/go"

	"github.com/prometheus/prom2json"
)

//export goProm2Json_bytes
func goProm2Json_bytes(data string) *C.char {
	var input io.Reader
	var err error

	// Wrap input data w/ io.Reader object (for ParseReader later)
	input = bytes.NewReader([]byte(data))

	mfChan := make(chan *dto.MetricFamily, 1024)
	go func() {
		if err := prom2json.ParseReader(input, mfChan); err != nil {
			log.Fatal("error reading metrics:", err)
		}
	}()

	result := []*prom2json.Family{}
	for mf := range mfChan {
		result = append(result, prom2json.NewFamily(mf))
	}
	jsonText, err := json.Marshal(result)
	if err != nil {
		log.Fatalln("error marshaling JSON:", err)
	}

	return C.CString(string(jsonText))
}

func main() {}
