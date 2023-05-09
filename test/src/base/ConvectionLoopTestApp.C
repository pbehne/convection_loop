//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "ConvectionLoopTestApp.h"
#include "ConvectionLoopApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

InputParameters
ConvectionLoopTestApp::validParams()
{
  InputParameters params = ConvectionLoopApp::validParams();
  return params;
}

ConvectionLoopTestApp::ConvectionLoopTestApp(InputParameters parameters) : MooseApp(parameters)
{
  ConvectionLoopTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

ConvectionLoopTestApp::~ConvectionLoopTestApp() {}

void
ConvectionLoopTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  ModulesApp::registerAllObjects<ConvectionLoopApp>(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"ConvectionLoopTestApp"});
    Registry::registerActionsTo(af, {"ConvectionLoopTestApp"});
  }
}

void
ConvectionLoopTestApp::registerApps()
{
  registerApp(ConvectionLoopApp);
  registerApp(ConvectionLoopTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
ConvectionLoopTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ConvectionLoopTestApp::registerAll(f, af, s);
}
extern "C" void
ConvectionLoopTestApp__registerApps()
{
  ConvectionLoopTestApp::registerApps();
}
